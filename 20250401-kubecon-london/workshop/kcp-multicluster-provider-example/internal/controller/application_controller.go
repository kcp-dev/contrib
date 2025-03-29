/*
Copyright 2025.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package controller

import (
	"context"
	"encoding/json"
	"fmt"

	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/util/intstr"
	"k8s.io/utils/ptr"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/controller/controllerutil"
	"sigs.k8s.io/controller-runtime/pkg/log"

	apisv1alpha1 "github.com/kcp-dev/multicluster-provider/examples/crd/api/v1alpha1"
)

const (
	// FinalizerName is the finalizer name for the Application CRD
	FinalizerName = "finalizer.apis.contrib.kcp.io/no-no-no"
)

// ApplicationReconciler reconciles a Application object
type ApplicationReconciler struct {
	client.Client
	Scheme *runtime.Scheme

	ProviderClient client.Client
}

// +kubebuilder:rbac:groups=apis.contrib.kcp.io,resources=applications,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups=apis.contrib.kcp.io,resources=applications/status,verbs=get;update;patch
// +kubebuilder:rbac:groups=apis.contrib.kcp.io,resources=applications/finalizers,verbs=update

// Reconcile is part of the main kubernetes reconciliation loop which aims to
// move the current state of the cluster closer to the desired state.
// TODO(user): Modify the Reconcile function to compare the state specified by
// the Application object against the actual cluster state, and then
// perform operations to make the cluster state reflect the state specified by
// the user.
//
// For more details, check Reconcile and its Result here:
// - https://pkg.go.dev/sigs.k8s.io/controller-runtime@v0.20.2/pkg/reconcile
func (r *ApplicationReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	_ = log.FromContext(ctx)

	obj := &apisv1alpha1.Application{}
	if err := r.Client.Get(ctx, req.NamespacedName, obj); err != nil {
		return ctrl.Result{}, client.IgnoreNotFound(err)
	}

	var secret corev1.Secret
	err := r.Client.Get(ctx, client.ObjectKey{
		Namespace: req.Namespace,
		Name:      obj.Spec.DatabaseSecretRef.Name,
	}, &secret)
	if err != nil {
		return ctrl.Result{
			Requeue: true,
		}, err
	}

	namespace, ok := obj.Annotations["kcp.io/cluster"]
	if !ok {
		return ctrl.Result{}, fmt.Errorf("cluster label not found")
	}

	deployment, err := getApplicationDeployment(obj, namespace)
	if err != nil {
		return ctrl.Result{}, err
	}

	_, err = controllerutil.CreateOrUpdate(ctx, r.ProviderClient, deployment, func() error {
		return nil
	})
	if err != nil {
		return ctrl.Result{}, err
	}

	svc, err := getApplicationService(obj, namespace)
	if err != nil {
		return ctrl.Result{}, err
	}

	_, err = controllerutil.CreateOrUpdate(ctx, r.ProviderClient, svc, func() error {
		return nil
	})
	if err != nil {
		return ctrl.Result{}, err
	}

	serverJson, err := getServerJson(obj, secret)
	if err != nil {
		return ctrl.Result{}, err
	}

	serverSecret := &corev1.Secret{
		ObjectMeta: metav1.ObjectMeta{
			Name:      obj.Name + "-server",
			Namespace: namespace,
			Finalizers: []string{
				FinalizerName,
			},
		},
		Data: map[string][]byte{
			"servers.json": serverJson,
		},
	}

	_, err = controllerutil.CreateOrUpdate(ctx, r.ProviderClient, serverSecret, func() error {
		return nil
	})
	if err != nil {
		return ctrl.Result{}, err
	}

	// Update the status
	obj.Status.Status = "Ready"
	obj.Status.ConnectionString = "kubectl port-forward svc/" + obj.Name + " 8080:8080 -n " + namespace

	if err := r.Client.Status().Update(ctx, obj); err != nil {
		return ctrl.Result{}, err
	}

	return ctrl.Result{}, nil
}

// SetupWithManager sets up the controller with the Manager.
func (r *ApplicationReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&apisv1alpha1.Application{}).
		Named("application").
		Complete(r)
}

func getServerJson(app *apisv1alpha1.Application, secret corev1.Secret) ([]byte, error) {
	d := map[string]interface{}{
		"Servers": map[string]interface{}{
			"1": map[string]string{
				"Name":  app.Name,
				"Group": "Servers",
				"Host":  "localhost",
			},
		},
	}

	return json.Marshal(d)
}

func getApplicationService(app *apisv1alpha1.Application, namespace string) (*corev1.Service, error) {
	return &corev1.Service{
		ObjectMeta: metav1.ObjectMeta{
			Name:      app.Name,
			Namespace: namespace,
			Finalizers: []string{
				FinalizerName,
			},
		},
		Spec: corev1.ServiceSpec{
			Selector: map[string]string{
				"app": app.Name,
			},
			Ports: []corev1.ServicePort{
				{
					Port:       8080,
					TargetPort: intstr.FromInt(80),
				},
			},
		},
	}, nil
}

func getApplicationDeployment(app *apisv1alpha1.Application, namespace string) (*appsv1.Deployment, error) {
	return &appsv1.Deployment{
		ObjectMeta: metav1.ObjectMeta{
			Name:      app.Name,
			Namespace: namespace,
			Finalizers: []string{
				FinalizerName,
			},
		},
		Spec: appsv1.DeploymentSpec{
			Replicas: ptr.To[int32](1),
			Selector: &metav1.LabelSelector{
				MatchLabels: map[string]string{
					"app": app.Name,
				},
			},
			Template: corev1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{
					Labels: map[string]string{
						"app": app.Name,
					},
				},
				Spec: corev1.PodSpec{
					Containers: []corev1.Container{
						{
							Name:            "pgadmin",
							Image:           "dpage/pgadmin4:9.1.0",
							ImagePullPolicy: corev1.PullIfNotPresent,
							Ports: []corev1.ContainerPort{
								{
									ContainerPort: 80,
								},
							},
							Env: []corev1.EnvVar{
								{
									Name:  "PGADMIN_DEFAULT_EMAIL",
									Value: "admin@kcp.io",
								},
								{
									Name:  "PGADMIN_DEFAULT_PASSWORD",
									Value: "admin",
								},
								{
									Name:  "PGADMIN_PORT",
									Value: "80",
								},
								{
									Name:  "PGADMIN_SETUP_EMAIL",
									Value: "admin@kcp.io",
								},
								{
									Name:  "PGADMIN_SETUP_PASSWORD",
									Value: "admin",
								},
								{
									Name:  "PGADMIN_CONFIG_SERVER_MODE",
									Value: "False",
								},
								{
									Name:  "PGADMIN_CONFIG_ENHANCED_COOKIE_PROTECTION",
									Value: "False",
								},
								{
									Name: "PGADMIN_SERVER_JSON_FILE",
									ValueFrom: &corev1.EnvVarSource{
										SecretKeyRef: &corev1.SecretKeySelector{
											Key: "servers.json",
											LocalObjectReference: corev1.LocalObjectReference{
												Name: app.Name + "-server",
											},
										},
									},
								},
							},
						},
					},
				},
			},
		},
	}, nil
}
