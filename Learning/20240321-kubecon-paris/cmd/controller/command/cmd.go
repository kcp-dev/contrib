package command

import (
	"context"
	"fmt"
	"io"
	"net/url"

	"github.com/faroshq/kcp-ml-shop/cmd/controller/options"
	configroot "github.com/faroshq/kcp-ml-shop/config/root"
	configtraining "github.com/faroshq/kcp-ml-shop/config/training"
	"github.com/faroshq/kcp-ml-shop/controller"
	kcpapiextensionsclientset "github.com/kcp-dev/client-go/apiextensions/client"
	kcpdynamic "github.com/kcp-dev/client-go/dynamic"
	"github.com/kcp-dev/kcp/pkg/cmd/help"
	kcpclusterclientset "github.com/kcp-dev/kcp/sdk/client/clientset/versioned/cluster"
	"github.com/spf13/cobra"

	"k8s.io/apimachinery/pkg/util/sets"
	"k8s.io/client-go/tools/clientcmd"
	logsapiv1 "k8s.io/component-base/logs/api/v1"
	"k8s.io/klog/v2"
)

func NewCommand(ctx context.Context, errout io.Writer) *cobra.Command {
	opts := options.NewOptions()

	// Default to -v=2
	opts.Logs.Verbosity = logsapiv1.VerbosityLevel(2)

	cmd := &cobra.Command{
		Use:   "server",
		Short: "ML Training manager",
		Long:  "Start the manager which managed all controllers for the ML Training manager",

		RunE: func(c *cobra.Command, args []string) error {
			if err := opts.Complete(); err != nil {
				return fmt.Errorf("error completing options: %v", err)
			}
			if err := opts.Validate(); err != nil {
				return err
			}

			return nil
		},
	}

	startCmd := &cobra.Command{
		Use:   "start",
		Short: "Start the controller manager",
		Long: Doc(`
			Start the controller manager

			The controller manager is in charge of starting the controllers reconciliating ML Training jobs.
		`),
		PersistentPreRunE: func(*cobra.Command, []string) error {
			return nil
		},
		RunE: func(cmd *cobra.Command, args []string) error {
			return Run(ctx, opts)
		},
	}

	initCmd := &cobra.Command{
		Use:   "init",
		Short: "Bootstrap the controller manager",
		Long: help.Doc(`
			Bootstrap the controller manager with the necessary resources/
			It will create hosting workspace and appropriate resources.

			Requires to run with privileged access to the KCP cluster.
		`),
		PersistentPreRunE: func(*cobra.Command, []string) error {
			return nil
		},
		RunE: func(cmd *cobra.Command, args []string) error {
			return Bootstrap(ctx, opts)
		},
	}
	opts.AddFlags(cmd.Flags())
	opts.AddFlags(startCmd.Flags())
	opts.AddFlags(initCmd.Flags())

	cmd.AddCommand(initCmd)
	cmd.AddCommand(startCmd)

	return cmd
}

func Run(ctx context.Context, o *options.Options) error {
	logger := klog.FromContext(ctx)
	logger.Info("instantiating controller")

	kcpClientConfigOverrides := &clientcmd.ConfigOverrides{
		CurrentContext: o.Context,
	}
	restConfig, err := clientcmd.NewNonInteractiveDeferredLoadingClientConfig(
		&clientcmd.ClientConfigLoadingRules{ExplicitPath: o.Kubeconfig},
		kcpClientConfigOverrides).ClientConfig()
	if err != nil {
		return err
	}
	restConfig.QPS = o.QPS
	restConfig.Burst = o.Burst

	h, err := url.Parse(restConfig.Host)
	if err != nil {
		return err
	}
	h.Path = ""
	restConfig.Host = h.String()

	mgr, err := controller.NewManager(ctx, restConfig)
	if err != nil {
		return err
	}
	mgr.Start(ctx)
	if err != nil {
		return err
	}
	<-ctx.Done()
	logger.Info("stopping")
	return nil
}

func Bootstrap(ctx context.Context, o *options.Options) error {
	logger := klog.FromContext(ctx)
	logger.Info("bootstrapping controller")

	kcpClientConfigOverrides := &clientcmd.ConfigOverrides{
		CurrentContext: o.Context,
	}
	restConfig, err := clientcmd.NewNonInteractiveDeferredLoadingClientConfig(
		&clientcmd.ClientConfigLoadingRules{ExplicitPath: o.Kubeconfig},
		kcpClientConfigOverrides).ClientConfig()
	if err != nil {
		return err
	}

	h, err := url.Parse(restConfig.Host)
	if err != nil {
		return err
	}
	h.Path = ""
	restConfig.Host = h.String()

	clusterKcpClient, err := kcpclusterclientset.NewForConfig(restConfig)
	if err != nil {
		return err
	}

	bootstrapApiExtensionsClusterClient, err := kcpapiextensionsclientset.NewForConfig(restConfig)
	if err != nil {
		return err
	}

	bootstrapDynamicClusterClient, err := kcpdynamic.NewForConfig(restConfig)
	if err != nil {
		return err
	}

	fakeBatteries := sets.New("")

	logger.Info("starting bootstrapping training assets")
	if err := configroot.Bootstrap(
		ctx,
		clusterKcpClient,
		bootstrapApiExtensionsClusterClient,
		bootstrapDynamicClusterClient,
		fakeBatteries,
	); err != nil {
		logger.Error(err, "failed to bootstrap training assets")
		return nil // don't klog.Fatal. This only happens when context is cancelled.
	}
	if err := configtraining.Bootstrap(
		ctx,
		clusterKcpClient,
		bootstrapApiExtensionsClusterClient,
		bootstrapDynamicClusterClient,
		fakeBatteries,
	); err != nil {
		logger.Error(err, "failed to bootstrap training assets")
		return nil // don't klog.Fatal. This only happens when context is cancelled.
	}

	logger.Info("finished bootstrapping training assets")
	return nil
}
