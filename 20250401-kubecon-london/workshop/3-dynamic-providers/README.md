# Dyanmic providers 

In this section we will explore dynamic providers, and how they can be used to create shared resources.

Lets prepare the kind cluster which will act as provider. In the 3rd terminal window:

```bash
source 1_config.sh
```

Configure sync agent pre-requisites on kcp side:

```bash
export KUBECONFIG=sync-agent.kubeconfig
kubectl ws use :root:providers
kubectl ws create database --enter
```

Lets create a placeholder APIExport:

```bash
kubectl create -f apis/export.yaml
```

Now lets swithc to kind cluster and start sync agent:

```bash
export KUBECONFIG=provider.kubeconfig
kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.25/releases/cnpg-1.25.1.yaml
```

Download API-Sync agent binary locally and run it:

TODO: Add binary publishing and downloads

```bash
export KUBECONFIG=provider.kubeconfig
# create sync resources
kubectl create -f https://raw.githubusercontent.com/kcp-dev/api-syncagent/refs/heads/main/deploy/crd/kcp.io/syncagent.kcp.io_publishedresources.yaml
kubectl create -f apis/resources-cluster.yaml
kubectl create -f apis/resources-database.yaml
./api-syncagent --namespace default --apiexport-ref postgresql.cnpg.io --kcp-kubeconfig=sync-agent.kubeconfig
```

Our placeholder APIExport now is managed by API-Sync agent. check the status of the APIExport:

```bash
kubectl get apiexport postgresql.cnpg.io -o yaml
```

Once this is done, we have postgres operator running in the provider cluster, and API-Sync agent making it 'shared' in the kcp cluster as service.

Lets create 2 consumers same way as we did with cowboys:

```bash
kubectl ws use :root:consumers
kubectl ws create pg --enter
kubectl kcp bind apiexport root:providers:database:postgresql.cnpg.io
# TODO: accepts all claims
  permissionClaims:
    - group: ""
      resource: "secrets"
      state: Accepted
      all: true
    - group: ""
      resource: "namespaces"
      all: true
      state: Accepted

```

Create a database cluster:

```bash
kubectl create -f apis/consumer-1-cluster.yaml
```

wait until Cluster is ready:

```bash
kubectl get cluster -o yaml
```

Now create database in this cluster:

```bash
kubectl create -f apis/consumer-1-database.yaml
```

Now once database is created, we can see the status of the database:

```bash
kubectl get database -o yaml
```

Our database is running in `Kind` cluster we provisioned before.
Lets check it:

```bash
export KUBECONFIG=provider.kubeconfig
kubectl get namespaces
NAME                 STATUS   AGE
29z92u57eft03ett     Active   4m26s
cnpg-system          Active   18m
default              Active   22m
kube-node-lease      Active   22m
kube-public          Active   22m
kube-system          Active   22m
local-path-storage   Active   22m
```

lets check namespace `29z92u57eft03ett`:

```bash
kubectl get cluster -n 29z92u57eft03ett
kubectl port-forward svc/kcp-rw 5432:5432 -n 29z92u57eft03ett
```

back to KCP cluster, we can see the database is running:

```bash
kubectl get cluster -o yaml
# Extract and decode the username
export PG_USERNAME=$(kubectl get secret kcp-superuser -o=jsonpath='{.data.username}' | base64 --decode)

# Extract and decode the password
export PG_PASSWORD=$(kubectl get secret kcp-superuser -o=jsonpath='{.data.password}' | base64 --decode)

# Generate the PostgreSQL connection string
echo "psql -U $PG_USERNAME -d one -h 127.0.0.1 -W $PG_PASSWORD"
```

```
SELECT * FROM pg_catalog.pg_tables WHERE schemaname = 'pg_catalog';
```

This now does some hacking to expose provider cluster database via port-forward. In production this would be done via proper ingress and service
and secret with connection stringds returned to the consumer workspace.

Now imagine you have cluster, serving as provider and every user gets its own workspace where they can provision any resources they want.
Ultimate Cloud Native Platform as a Service.