package training

import (
	"context"
	"fmt"
	"time"

	trainingv1alpha1 "github.com/faroshq/kcp-ml-shop/apis/training/v1alpha1"
	clientset "github.com/faroshq/kcp-ml-shop/client/clientset/versioned/cluster"
	trainingclientset "github.com/faroshq/kcp-ml-shop/client/clientset/versioned/typed/training/v1alpha1"
	trainingv1alpha1informers "github.com/faroshq/kcp-ml-shop/client/informers/externalversions/training/v1alpha1"
	trainingv1alpha1listers "github.com/faroshq/kcp-ml-shop/client/listers/training/v1alpha1"
	kcpcache "github.com/kcp-dev/apimachinery/v2/pkg/cache"
	"github.com/kcp-dev/kcp/pkg/logging"
	"github.com/kcp-dev/kcp/pkg/reconciler/committer"

	apierrors "k8s.io/apimachinery/pkg/api/errors"
	utilerrors "k8s.io/apimachinery/pkg/util/errors"
	"k8s.io/apimachinery/pkg/util/runtime"
	"k8s.io/apimachinery/pkg/util/wait"
	"k8s.io/client-go/tools/cache"
	"k8s.io/client-go/util/workqueue"
	"k8s.io/klog/v2"
)

type reconcileStatus int

const (
	reconcileStatusStopAndRequeue reconcileStatus = iota
	reconcileStatusContinue
	reconcileStatusStopWaitAndRequeue
)

const ControllerName = "training-ml-controller"

type modelResource = committer.Resource[*trainingv1alpha1.ModelSpec, *trainingv1alpha1.ModelStatus]

type Controller struct {
	shard         string
	queue         workqueue.RateLimitingInterface
	clusterClient clientset.ClusterInterface

	modelsIndexer cache.Indexer
	modelsLister  trainingv1alpha1listers.ModelClusterLister

	// commit creates a patch and submits it, if needed.
	commit func(ctx context.Context, old, new *modelResource) error
}

func NewController(
	shard string,
	clusterClient clientset.ClusterInterface,
	modelsInformer trainingv1alpha1informers.ModelClusterInformer,
) *Controller {
	c := &Controller{
		shard:         shard,
		queue:         workqueue.NewNamedRateLimitingQueue(workqueue.DefaultControllerRateLimiter(), ControllerName),
		clusterClient: clusterClient,

		modelsIndexer: modelsInformer.Informer().GetIndexer(),
		modelsLister:  modelsInformer.Lister(),

		commit: committer.NewCommitter[*trainingv1alpha1.Model, trainingclientset.ModelInterface, *trainingv1alpha1.ModelSpec, *trainingv1alpha1.ModelStatus](clusterClient.TrainingV1alpha1().Models()),
	}

	// Watch for events related to Models
	_, _ = modelsInformer.Informer().AddEventHandler(cache.ResourceEventHandlerFuncs{
		AddFunc:    func(obj interface{}) { c.enqueue(obj) },
		UpdateFunc: func(_, obj interface{}) { c.enqueue(obj) },
		DeleteFunc: func(obj interface{}) {}, // TODO: Delete user to propagate delete logical cluster
	})

	return c
}

func (c *Controller) enqueue(obj interface{}) {
	logger := logging.WithObject(logging.WithReconciler(klog.Background(), ControllerName), obj.(*trainingv1alpha1.Model))

	key, err := kcpcache.MetaClusterNamespaceKeyFunc(obj)
	if err != nil {
		runtime.HandleError(err)
		return
	}

	cluster, _, name, err := kcpcache.SplitMetaClusterNamespaceKey(key)
	if err != nil {
		runtime.HandleError(err)
		return
	}

	model, err := c.modelsLister.Cluster(cluster).Get(name)
	if err != nil {
		runtime.HandleError(err)
		return
	}
	logger.Info("enqueueing model", "name", model.Name)
	if model.Status.Phase != trainingv1alpha1.ModelPhaseCompleted {
		c.queue.Add(key)
	} else {
		logger.Info("model has finished", "name", model.Name)
	}
}

// Start starts the controller workers.
func (c *Controller) Start(ctx context.Context, numThreads int) {
	defer runtime.HandleCrash()
	defer c.queue.ShutDown()

	logger := logging.WithReconciler(klog.FromContext(ctx), ControllerName)
	ctx = klog.NewContext(ctx, logger)
	logger.Info("Starting controller")
	defer logger.Info("Shutting down controller")

	for i := 0; i < numThreads; i++ {
		go wait.UntilWithContext(ctx, c.startWorker, time.Second)
	}

	<-ctx.Done()
}

func (c *Controller) startWorker(ctx context.Context) {
	for c.processNextWorkItem(ctx) {
	}
}

func (c *Controller) processNextWorkItem(ctx context.Context) bool {
	// Wait until there is a new item in the working queue
	k, quit := c.queue.Get()
	if quit {
		return false
	}
	key := k.(string)

	logger := logging.WithQueueKey(klog.FromContext(ctx), key)
	ctx = klog.NewContext(ctx, logger)
	logger.Info("processing key")

	// No matter what, tell the queue we're done with this key, to unblock
	// other workers.
	defer c.queue.Done(key)

	if requeue, err := c.process(ctx, key); err != nil {
		runtime.HandleError(fmt.Errorf("%q controller failed to sync %q, err: %w", ControllerName, key, err))
		c.queue.AddRateLimited(key)
		return true
	} else if requeue {
		// only requeue if we didn't error, but we still want to requeue
		c.queue.Add(key)
		return true
	}
	c.queue.Forget(key)
	return true
}

func (c *Controller) process(ctx context.Context, key string) (bool, error) {
	logger := klog.FromContext(ctx)

	cluster, _, name, err := kcpcache.SplitMetaClusterNamespaceKey(key)
	if err != nil {
		runtime.HandleError(err)
		return false, nil
	}

	currentModel, err := c.modelsLister.Cluster(cluster).Get(name)
	if err != nil {
		logger.Error(err, "failed to get model")
		return false, nil
	}

	if !apierrors.IsNotFound(err) && currentModel.GetDeletionTimestamp() != nil {
		logger.Info("model was deleted")
		return false, nil
	}

	old := currentModel
	model := currentModel.DeepCopy()

	var errs []error
	requeue, err := c.reconcile(ctx, cluster, model)
	if err != nil {
		errs = append(errs, err)
	}

	// If the object being reconciled changed as a result, update it.
	oldResource := &modelResource{ObjectMeta: old.ObjectMeta, Spec: &old.Spec, Status: &old.Status}
	newResource := &modelResource{ObjectMeta: model.ObjectMeta, Spec: &model.Spec, Status: &model.Status}
	if err := c.commit(ctx, oldResource, newResource); err != nil {
		errs = append(errs, err)
	}

	return requeue, utilerrors.NewAggregate(errs)
}
