package controller

import (
	"context"
	"fmt"
	"strings"
	"time"

	trainingclusterclientset "github.com/faroshq/kcp-ml-shop/client/clientset/versioned/cluster"
	traininginformers "github.com/faroshq/kcp-ml-shop/client/informers/externalversions"
	apisv1alpha1 "github.com/kcp-dev/kcp/sdk/apis/apis/v1alpha1"
	kcpclusterclientset "github.com/kcp-dev/kcp/sdk/client/clientset/versioned/cluster"
	"github.com/kcp-dev/logicalcluster/v3"
	"golang.org/x/sync/errgroup"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/pkg/version"
	"k8s.io/client-go/rest"
	"k8s.io/klog/v2"
)

const (
	trainingApiExportName = "training.faros.sh"
	trainingClusterPath   = "root:ml:training"
	resyncPeriod          = 10 * time.Hour
)

type Manager struct {
	shards map[string]shardManager
}

// ShardManager is the interface for the manager for a shard
type shardManager struct {
	name         string
	clientConfig rest.Config

	trainingSharedInformerFactory traininginformers.SharedInformerFactory

	stopCh   chan struct{}
	syncedCh chan struct{}
}

// NewManager creates a manager able to start controllers
func NewManager(ctx context.Context, kcpAdmin *rest.Config) (*Manager, error) {
	logger := klog.FromContext(ctx)
	m := &Manager{
		shards: map[string]shardManager{},
	}

	logger.Info("setting up proxy manager")
	clients, err := restConfigForAPIExport(ctx, kcpAdmin, trainingApiExportName)
	if err != nil {
		return nil, err
	}
	shards, err := setupShardManager(ctx, clients)
	if err != nil {
		return nil, err
	}
	m.shards = shards

	return m, nil
}

// Start starts informers and controller instances
func (m Manager) Start(ctx context.Context) error {
	logger := klog.FromContext(ctx)

	logger.V(2).Info("starting manager")
	g := errgroup.Group{}

	for _, s := range m.shards {
		ss := s
		g.Go(func() error {
			if err := ss.installMLModelsController(ctx); err != nil {
				return err
			}
			err := ss.start(ctx, "trainings")
			if err != nil {
				return err
			}
			return nil
		})
	}

	return g.Wait()
}

func setupShardManager(ctx context.Context, clients []rest.Config) (map[string]shardManager, error) {
	logger := klog.FromContext(ctx)
	logger.Info("shards found", "count", len(clients))
	shards := make(map[string]shardManager, len(clients))
	for _, c := range clients {
		name := strings.Split(strings.TrimPrefix(c.Host, "https://"), ".")[0]
		logger.Info("Shard", "name", name, "host", c.Host)
		s := shardManager{
			name:         name,
			clientConfig: c,
			stopCh:       make(chan struct{}),
			syncedCh:     make(chan struct{}),
		}
		informerProxyClient, err := trainingclusterclientset.NewForConfig(&s.clientConfig)
		if err != nil {
			return nil, err
		}

		s.trainingSharedInformerFactory = traininginformers.NewSharedInformerFactoryWithOptions(
			informerProxyClient,
			resyncPeriod,
		)

		shards[s.name] = s
	}

	return shards, nil
}

func (s *shardManager) start(ctx context.Context, export string) error {
	logger := klog.FromContext(ctx).WithValues("shard", s.name, "export", export)

	s.trainingSharedInformerFactory.Start(s.stopCh)

	logger.Info("waiting for kube informers sync")
	wg := errgroup.Group{}
	wg.Go(func() error {
		logger.Info("waiting for trainingSharedInformerFactory informers")
		s.trainingSharedInformerFactory.WaitForCacheSync(s.stopCh)
		logger.Info("trainingSharedInformerFactory informers synced")
		return nil
	})
	wg.Wait()

	logger.Info("all informers synced, ready to start controllers")
	close(s.syncedCh)
	return nil
}

// restConfigForAPIExport returns a *rest.Config properly configured to communicate with the endpoint for the
// APIExport's virtual workspace. cfg is the bootstrap config, shardsClientConfig is the config for the shards clusters.
func restConfigForAPIExport(ctx context.Context, cfg *rest.Config, apiExportName string) ([]rest.Config, error) {
	logger := klog.FromContext(ctx)
	logger.V(2).Info("getting apiexport")

	bootstrapConfig := rest.CopyConfig(cfg)
	proxyVersion := version.Get().GitVersion
	rest.AddUserAgent(bootstrapConfig, "kcp#training/bootstrap/"+proxyVersion)
	bootstrapClient, err := kcpclusterclientset.NewForConfig(bootstrapConfig)
	if err != nil {
		return nil, err
	}

	var apiExport *apisv1alpha1.APIExport
	cluster := logicalcluster.NewPath(trainingClusterPath)

	if apiExportName != "" {
		if apiExport, err = bootstrapClient.ApisV1alpha1().APIExports().Cluster(cluster).Get(ctx, apiExportName, metav1.GetOptions{}); err != nil {
			return nil, fmt.Errorf("error getting APIExport %q: %w", apiExportName, err)
		}
	} else {
		logger := klog.FromContext(ctx)
		logger.V(2).Info("api-export-name is empty - listing")
		exports := &apisv1alpha1.APIExportList{}
		if exports, err = bootstrapClient.ApisV1alpha1().APIExports().List(ctx, metav1.ListOptions{}); err != nil {
			return nil, fmt.Errorf("error listing APIExports: %w", err)
		}
		if len(exports.Items) == 0 {
			return nil, fmt.Errorf("no APIExport found")
		}
		if len(exports.Items) > 1 {
			return nil, fmt.Errorf("more than one APIExport found")
		}
		apiExport = &exports.Items[0]
	}

	if len(apiExport.Status.VirtualWorkspaces) < 1 {
		return nil, fmt.Errorf("APIExport %q status.virtualWorkspaces is empty", apiExportName)
	}

	var results []rest.Config
	// TODO(mjudeikis): For sharding support we would need to interact with the APIExportEndpointSlice API
	// rather than APIExport. We would then have an URL per shard. For now we just get list of all and move on.
	for _, ws := range apiExport.Status.VirtualWorkspaces {
		logger.Info("virtual workspace", "url", ws.URL)
		cfg = rest.CopyConfig(cfg)
		cfg.Host = ws.URL
		results = append(results, *cfg)
	}

	return results, nil
}
