---
title: "04: Application providers"
---

# Application providers

In our last exercise of this workshop we'll take a look at a kcp-native application, that uses [sigs.k8s.io/multicluster-runtime](https://github.com/kubernetes-sigs/multicluster-runtime) to run a kcp provider, and reconciles the deployment across workspaces.

## Going native

After the great kick-off with the PostgreSQL-as-a-Service business, the folks back at **SQL<sup>3</sup> Co.** have decided to give in, and give their kcp-aware customers a treat. They realised that some of the users don't really like the `psql` CLI interface, and would prefer web-based [pgAdmin](https://www.pgadmin.org/) instead. And so they invested into building a kcp-native pgAdmin provider, with the same principles as we've seen up until now: the workloads stay with the service owner, the spec is consumer's.

To accomplish that, they say all they had to use was:

* [kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) to scaffold the project and CRDs,
* [sigs.k8s.io/multicluster-runtime](https://github.com/kubernetes-sigs/multicluster-runtime) to provide multicluster manager, controller and reconciler functionalities,
* [github.com/kcp-dev/multicluster-provider/virtualworkspace]() to interact with kcp virtual workspaces,
* [github.com/kcp-dev/kcp/sdk]() to add in kcp schemas,
* and lastly, [github.com/cloudnative-pg/cloudnative-pg](https://github.com/cloudnative-pg/cloudnative-pg) to be able to work with _postgresql.cnpg.io_ resources.

We won't go into any implementation details here, but you are very welcome to inspect and play around with the code yourself at <>. The kcp-aware bits are clearly marked to see what multicluster bits need to be added into the kubebuilder-generated base. As far as the complexity goes, we hope you will find it quite underwhelming :)

## There is an App in my WS! 🤌

The Application brought to you by **SQL<sup>3</sup> Co.** has a CRD definition and a controller that comes with it, and that they are running (we'll see how right after this) on their infrastructure. They were also nice enough prepare an APIResourceSchema too! For us at kcp land though, not much will change since the last time. In a provider workspace we create an APIExport for the prepared APIResourceSchema, and then we add consumers by binding to that export.

!!! Important

    === "Bash/ZSH"

        ```shell
        export WORKSHOP_ROOT="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop"
        export EXERCISE_DIR="${WORKSHOP_ROOT}/04-application-providers"
        export KUBECONFIGS_DIR="${WORKSHOP_ROOT}/kubeconfigs"
        export KREW_ROOT="${WORKSHOP_ROOT}/bin/.krew"
        export PATH="${WORKSHOP_ROOT}/bin/.krew/bin:${WORKSHOP_ROOT}/bin:${PATH}"

        # Stashing our admin.kubeconfig away for when we deploy the multicluster provider.
        cp ${KUBECONFIGS_DIR}/admin.kubeconfig ${KUBECONFIGS_DIR}/mcp-app.kubeconfig
        export KUBECONFIG="${KUBECONFIGS_DIR}/mcp-app.kubeconfig"
        ```

    === "Fish"

        ```fish
        set -gx WORKSHOP_ROOT (git rev-parse --show-toplevel)/20250401-kubecon-london/workshop
        set -gx EXERCISE_DIR $WORKSHOP_ROOT/04-application-providers
        set -gx KUBECONFIGS_DIR "${WORKSHOP_ROOT}/kubeconfigs"
        set -gx KREW_ROOT $WORKSHOP_ROOT/bin/.krew
        set -gx PATH $WORKSHOP_ROOT/bin/.krew/bin $WORKSHOP_ROOT/bin $PATH"

        # Stashing our admin.kubeconfig away for when we deploy the multicluster provider.
        cp $KUBECONFIGS_DIR/admin.kubeconfig $KUBECONFIGS_DIR/mcp-app.kubeconfig
        set -gx KUBECONFIG $KUBECONFIGS_DIR/mcp-app.kubeconfig
        ```

We'll use `:root:providers:application` workspace for our pgAdmin app export:

```shell
kubectl ws use :root:providers
kubectl ws create application --enter
kubectl apply -f $EXERCISE_DIR/apis/apiresourceschema.yaml
kubectl apply -f $EXERCISE_DIR/apis/export.yaml
```

And now a consumer:

```shell
kubectl ws :root:consumers:pg
kubectl kcp bind apiexport root:providers:application:apis.contrib.kcp.io --accept-permission-claim secrets.core
kubectl apply -f $EXERCISE_DIR/apis/application.yaml
```

What does the application look like?

```yaml
apiVersion: apis.contrib.kcp.io/v1alpha1
kind: Application
metadata:
  name: application-kcp
spec:
  databaseRef: db-one
  databaseSecretRef:
    name: kcp-superuser
```

It references the database we've created earlier, and the Secret with credentials to access it. Meanwhile, a word has got out to **SQL<sup>3</sup> Co.** that we are ready to use their fancy new Application reconciler, and so they ran this command--in a separate terminal and just left it running:

```shell title="Starting the mcp-app"
kubectl ws use :root:providers:application
mcp-example-crd --server=$(kubectl get apiexport apis.contrib.kcp.io -o jsonpath="{.status.virtualWorkspaces[0].url}") \
  --provider-kubeconfig ${KUBECONFIGS_DIR}/provider.kubeconfig
```

```shell-session title="View of the service owner cluster"
$ export KUBECONFIG=$KUBECONFIGS_DIR/provider.kubeconfig
$ kubectl get namespaces
# get namespace inquestion
$ KUBECONFIG=$KUBECONFIGS_DIR/provider.kubeconfig kubectl -n 1yaxsslokc5aoqme get all
NAME                                   READY   STATUS    RESTARTS   AGE
pod/application-kcp-578c5dd4df-fwlgw   1/1     Running   0          29s
pod/kcp-1                              1/1     Running   0          10m

NAME                      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/application-kcp   ClusterIP   10.96.68.251   <none>        8080/TCP   29s
service/kcp-r             ClusterIP   10.96.89.104   <none>        5432/TCP   10m
service/kcp-ro            ClusterIP   10.96.69.97    <none>        5432/TCP   10m
service/kcp-rw            ClusterIP   10.96.33.11    <none>        5432/TCP   10m

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/application-kcp   1/1     1            1           29s

NAME                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/application-kcp--578c5dd4df      1         1         1       29s
```

Continuing in our consumer workspace, let's check the Application object!

```shell-session
$ kubectl get application application-kcp -o json
{
    "apiVersion": "apis.contrib.kcp.io/v1alpha1",
    "kind": "Application",
    "metadata": {
        "annotations": {
            "kcp.io/cluster": "1yaxsslokc5aoqme"
        },
...
    "status": {
        "connectionString": "kubectl port-forward svc/application-kcp 8080:8080 -n 1yaxsslokc5aoqme",
        "status": "Ready"
    }
}
```

Now that's some weird connection string! Similar to what we did in the previous exercise, we didn't want to have our demo setup too complex, and so for the sake of brevity, let's pretend that port forwarding is an actual Ingress, and open up the connection.



```shell
KUBECONFIG=$KUBECONFIGS_DIR/provider.kubeconfig kubectl port-forward svc/application-kcp 8080:8080 -n 1yaxsslokc5aoqme
```

### Drum-roll 🥁🥁🥁

The last thing for you to do is to open up your browser, and visit `localhost:8080` using web-previou tab in google shell or your machine!

## High-five! 🚀🚀🚀

Congratulations, you've reached the finishing line! Great job!

This was a lot to take in, so let's recap. We've gone through basic concepts of kcp, what proper resource isolation looks like, but also how APIs can be shared. We've also learnt that we can specify what resources to share, limiting the scope of what a provider and consumer can reach. Using those principles we've been able to build consumer-producer relationship between Kubernetes endpoints: not only inside a single kcp instance, but with external clusters too. We've also peaked into multicluster controllers and reconcilers, where the options to inovate are vast. We invite you to give it a try, and see how your Kubernetes infrastructure could benefit from a true SaaS approach, with kcp!

### Where to next

More kcp talks at this conference:

* You are here: [Tutorial: Exploring Multi-Tenant Kubernetes APIs and Controllers With Kcp - Robert Vasek, Clyso GmbH; Nabarun Pal, Independent; Varsha Narsing, Red Hat; Marko Mudrinic, Kubermatic GmbH; Mangirdas Judeikis, Cast AI](https://kccnceu2025.sched.com/event/1tx6b/tutorial-exploring-multi-tenant-kubernetes-apis-and-controllers-with-kcp-robert-vasek-clyso-gmbh-nabarun-pal-independent-varsha-narsing-red-hat-marko-mudrinic-kubermatic-gmbh-mangirdas-judeikis-cast-ai?iframe=no&w=100%&sidebar=yes&bg=no)
* **Thursday**, 3 April: [Extending Kubernetes Resource Model (KRM) Beyond Kubernetes Workloads - Mangirdas Judeikis, Cast AI & Nabarun Pal, Independent](https://kccnceu2025.sched.com/event/1txAB/extending-kubernetes-resource-model-krm-beyond-kubernetes-workloads-mangirdas-judeikis-cast-ai-nabarun-pal-independent?iframe=no&w=100%&sidebar=yes&bg=no)
* also **Thursday**, 3 April: [Dynamic Multi-Cluster Controllers With Controller-runtime - Marvin Beckers, Kubermatic & Stefan Schimanski, Upbound](https://kccnceu2025.sched.com/event/1txFM/dynamic-multi-cluster-controllers-with-controller-runtime-marvin-beckers-kubermatic-stefan-schimanski-upbound?iframe=no&w=100%&sidebar=yes&bg=no)

After this conference:

* Homepage: [www.kcp.io](https://www.kcp.io/)
* The [`#kcp-dev` channel](https://app.slack.com/client/T09NY5SBT/C021U8WSAFK) in the [Kubernetes Slack workspace](https://slack.k8s.io).
* Our mailing lists:
    * [kcp-dev](https://groups.google.com/g/kcp-dev) for development discussions.
    * [kcp-users](https://groups.google.com/g/kcp-users) for discussions among users and potential users.
* By joining the kcp-dev mailing list, you should receive an invite to our bi-weekly community meetings.
* See recordings of past community meetings on [YouTube](https://www.youtube.com/channel/UCfP_yS5uYix0ppSbm2ltS5Q).
* The next community meeting dates are available via our [CNCF community group](https://community.cncf.io/kcp/).
* Check the [community meeting notes document](https://docs.google.com/document/d/1PrEhbmq1WfxFv1fTikDBZzXEIJkUWVHdqDFxaY1Ply4) for future and past meeting agendas.
* Browse the [shared Google Drive](https://drive.google.com/drive/folders/1FN7AZ_Q1CQor6eK0gpuKwdGFNwYI517M?usp=sharing) to share design docs, notes, etc.
    * Members of the kcp-dev mailing list can view this drive.
