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
	"strings"

	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/types"
	"k8s.io/apimachinery/pkg/util/intstr"
	"k8s.io/utils/ptr"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/controller/controllerutil"
	"sigs.k8s.io/controller-runtime/pkg/log"

	cnpgapiv1 "github.com/cloudnative-pg/cloudnative-pg/api/v1"

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

	app := &apisv1alpha1.Application{}
	if err := r.Client.Get(ctx, req.NamespacedName, app); err != nil {
		return ctrl.Result{}, client.IgnoreNotFound(err)
	}

	var secret corev1.Secret
	err := r.Client.Get(ctx, client.ObjectKey{
		Namespace: req.Namespace,
		Name:      app.Spec.DatabaseSecretRef.Name,
	}, &secret)
	if err != nil {
		return ctrl.Result{
			Requeue: true,
		}, err
	}

	namespace, ok := app.Annotations["kcp.io/cluster"]
	if !ok {
		return ctrl.Result{}, fmt.Errorf("cluster label not found")
	}

	var db cnpgapiv1.Database
	err = r.ProviderClient.Get(ctx, types.NamespacedName{
		Namespace: namespace,
		Name:      app.Spec.DatabaseRef,
	}, &db)
	if err != nil {
		return ctrl.Result{}, err
	}

	var dbCluster cnpgapiv1.Cluster
	err = r.ProviderClient.Get(ctx, types.NamespacedName{
		Namespace: namespace,
		Name:      db.GetClusterRef().Name,
	}, &dbCluster)
	if err != nil {
		return ctrl.Result{}, err
	}

	pgpass := newPgpassData(&db, &dbCluster, secret, namespace)

	deployment, err := getApplicationDeployment(pgpass, app, namespace)
	if err != nil {
		return ctrl.Result{}, err
	}

	_, err = controllerutil.CreateOrUpdate(ctx, r.ProviderClient, deployment, func() error {
		return nil
	})
	if err != nil {
		return ctrl.Result{}, err
	}

	svc, err := getApplicationService(app, namespace)
	if err != nil {
		return ctrl.Result{}, err
	}

	_, err = controllerutil.CreateOrUpdate(ctx, r.ProviderClient, svc, func() error {
		return nil
	})
	if err != nil {
		return ctrl.Result{}, err
	}

	serverJson, err := pgpass.toServersJson()
	if err != nil {
		return ctrl.Result{}, err
	}

	serverConfig := &corev1.ConfigMap{
		ObjectMeta: metav1.ObjectMeta{
			Name:      serverJsonConfigMapName(app),
			Namespace: namespace,
			Finalizers: []string{
				FinalizerName,
			},
		},
		Data: map[string]string{
			"servers.json": string(serverJson),
		},
	}

	_, err = controllerutil.CreateOrUpdate(ctx, r.ProviderClient, serverConfig, func() error {
		return nil
	})
	if err != nil {
		return ctrl.Result{}, err
	}

	// Update the status
	app.Status.Status = "Ready"
	app.Status.ConnectionString = "kubectl port-forward svc/" + app.Name + " 8080:8080 -n " + namespace

	if err := r.Client.Status().Update(ctx, app); err != nil {
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

func serverJsonConfigMapName(app *apisv1alpha1.Application) string {
	return fmt.Sprintf("%s-servers", app.Name)
}

func pgsqlServerHost(db *cnpgapiv1.Database) string {
	return fmt.Sprintf("%s-rw.%s.svc.cluster.local", db.GetClusterRef().Name, db.Namespace)
}

type pgpassData struct {
	Name          string
	Group         string
	Host          string
	Port          int
	Username      string
	PassFile      string
	SSLMode       string
	MaintenanceDB string
	initDb        string
	createdDb     string
	secret        string
}

func newPgpassData(
	db *cnpgapiv1.Database,
	dbCluster *cnpgapiv1.Cluster,
	secret corev1.Secret,
	namespace string,
) *pgpassData {
	return &pgpassData{
		Name:          dbCluster.Name,
		Group:         "Servers",
		Host:          pgsqlServerHost(db),
		Port:          5432,
		Username:      string(secret.Data["username"]),
		PassFile:      "/tmp/pgpassfile", // We don't have perms to write to /pgadmin4 where this normally would be.
		SSLMode:       "prefer",
		MaintenanceDB: "postgres",
		initDb:        dbCluster.GetApplicationDatabaseName(),
		createdDb:     db.Spec.Name,
		secret:        string(secret.Data["password"]),
	}
}

func (data *pgpassData) toServersJson() ([]byte, error) {
	// See https://www.pgadmin.org/docs/pgadmin4/latest/import_export_servers.html#json-format.
	return json.Marshal(
		map[string]interface{}{
			"Servers": map[string]interface{}{
				"1": data,
			},
		},
	)
}

func (data *pgpassData) toPassfileContent() string {
	var sb strings.Builder
	for _, dbName := range []string{data.MaintenanceDB, data.initDb, data.createdDb} {
		if dbName == "" {
			continue
		}
		// See https://www.postgresql.org/docs/current/libpq-pgpass.html.
		sb.WriteString(fmt.Sprintf("%s:%d:%s:%s:%s\n",
			data.Host, data.Port, dbName, data.Username, data.secret))
	}

	return sb.String()
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

func getApplicationDeployment(
	pgpass *pgpassData,
	app *apisv1alpha1.Application,
	namespace string,
) (*appsv1.Deployment, error) {
	const serverConfigVolume = "server-config"
	const serverSecretVolume = "server-secret"
	const passFileVolume = "passfile-dir"
	const serverPort = 5432

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
					Volumes: []corev1.Volume{
						{
							Name: serverConfigVolume,
							VolumeSource: corev1.VolumeSource{
								ConfigMap: &corev1.ConfigMapVolumeSource{
									LocalObjectReference: corev1.LocalObjectReference{
										Name: serverJsonConfigMapName(app),
									},
								},
							},
						},
					},
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
							VolumeMounts: []corev1.VolumeMount{
								{
									Name:      serverConfigVolume,
									MountPath: "/pgadmin4/servers.json",
									SubPath:   "servers.json",
								},
							},
							Command: []string{"/bin/bash", "-c",
								// We are leaking secrets to container definition!
								// This is just a tech demo, and code brevity takes precedence.
								// Don't use in production!
								fmt.Sprintf(`
    								echo '%[1]s' > %[2]s && chmod 0600 %[2]s \
    								&& /entrypoint.sh
    								`, pgpass.toPassfileContent(), pgpass.PassFile)},
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
							},
						},
					},
				},
			},
		},
	}, nil
}
