package training

import (
	"context"

	trainingv1alpha1 "github.com/faroshq/kcp-ml-shop/apis/training/v1alpha1"
	conditionsv1alpha1 "github.com/kcp-dev/kcp/sdk/apis/third_party/conditions/apis/conditions/v1alpha1"
	"github.com/kcp-dev/kcp/sdk/apis/third_party/conditions/util/conditions"
	corev1 "k8s.io/api/core/v1"

	"k8s.io/klog/v2"
)

type fakeStatusReconciler struct {
	getShard func() string
}

func (c *fakeStatusReconciler) reconcile(ctx context.Context, model *trainingv1alpha1.Model) (reconcileStatus, error) {
	logger := klog.FromContext(ctx)
	logger.Info("reconciling model", "name", model.Name)

	switch c.getShard() {
	case "root", "alpha":
		model.Status.Location = "westeurope"
	case "beta":
		model.Status.Location = "us-west"
	default:
		model.Status.Location = c.getShard()
	}

	switch model.Status.Phase {
	case trainingv1alpha1.ModelPhasePending:
		model.Status.Phase = trainingv1alpha1.ModelPhaseAccepted
		conditions.Set(model, &conditionsv1alpha1.Condition{
			Type:    ModelComputeStatus,
			Status:  corev1.ConditionTrue,
			Reason:  "Pending",
			Message: "Looking for compute resources",
		})
		return reconcileStatusStopWaitAndRequeue, nil
	case trainingv1alpha1.ModelPhaseAccepted:
		conditions.Set(model, &conditionsv1alpha1.Condition{
			Type:    ModelComputeStatus,
			Status:  corev1.ConditionTrue,
			Reason:  "Running",
			Message: "Compute allocated",
		})
		model.Status.Phase = trainingv1alpha1.ModelPhaseRunning
		return reconcileStatusStopWaitAndRequeue, nil
	case trainingv1alpha1.ModelPhaseRunning:
		conditions.Set(model, &conditionsv1alpha1.Condition{
			Type:    ModelComputeStatus,
			Status:  corev1.ConditionTrue,
			Reason:  "Completed",
			Message: "Compute released",
		})
		model.Status.Phase = trainingv1alpha1.ModelPhaseCompleted
		return reconcileStatusStopAndRequeue, nil
	}

	return reconcileStatusContinue, nil
}

// These are valid conditions of model.
const (
	// ModelComputeStatus represents status of the compute process for this model.
	ModelComputeStatus conditionsv1alpha1.ConditionType = "ModelComputeStatus"
)
