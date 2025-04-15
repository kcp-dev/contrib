package training

import (
	"context"
	"time"

	trainingv1alpha1 "github.com/faroshq/kcp-ml-shop/apis/training/v1alpha1"
	"github.com/kcp-dev/logicalcluster/v3"

	utilserrors "k8s.io/apimachinery/pkg/util/errors"
)

type reconciler interface {
	reconcile(ctx context.Context, user *trainingv1alpha1.Model) (reconcileStatus, error)
}

func (c *Controller) reconcile(ctx context.Context, _ logicalcluster.Name, user *trainingv1alpha1.Model) (bool, error) {
	// cluster := logicalcluster.From(user)
	// full := cluster.String()
	// path := logicalcluster.NewPath(full)

	reconcilers := []reconciler{
		&fakeStatusReconciler{
			getShard: func() string {
				return c.shard
			},
		},
	}

	var errs []error

	requeue := false
	for _, r := range reconcilers {
		var err error
		var status reconcileStatus
		status, err = r.reconcile(ctx, user)
		if err != nil {
			errs = append(errs, err)
		}
		if status == reconcileStatusStopAndRequeue {
			requeue = true
			break
		}
		if status == reconcileStatusStopWaitAndRequeue {
			requeue = true
			time.Sleep(20 * time.Second) // for demonstration purposes only
			break
		}
	}

	return requeue, utilserrors.NewAggregate(errs)

}
