package controller

import (
	"context"

	clusterclientset "github.com/faroshq/kcp-ml-shop/client/clientset/versioned/cluster"
	"github.com/faroshq/kcp-ml-shop/reconcilers/training"

	"k8s.io/client-go/rest"
	"k8s.io/klog/v2"
)

func (s *shardManager) installMLModelsController(ctx context.Context) error {
	logger := klog.FromContext(ctx).WithValues("shard", s.name, "controller", training.ControllerName)

	config := rest.CopyConfig(&s.clientConfig)
	config = rest.AddUserAgent(config, training.ControllerName)
	clusterClient, err := clusterclientset.NewForConfig(config)
	if err != nil {
		return err
	}

	c := training.NewController(
		s.name,
		clusterClient,
		s.trainingSharedInformerFactory.Training().V1alpha1().Models(),
	)
	if err != nil {
		return err
	}

	go func() {
		// Wait for shared informer factories to by synced.
		<-s.syncedCh
		logger.Info("starting controller")
		ctx = klog.NewContext(ctx, logger)
		c.Start(ctx, 2)
	}()

	return nil
}
