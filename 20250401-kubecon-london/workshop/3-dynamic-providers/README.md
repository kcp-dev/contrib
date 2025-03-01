# Dyanmic providers 

In this section we will explore dynamic providers, and how they can be used to create shared resources.

Lets prepare the kind cluster which will act as provider:

```bash
kind create cluster --name provider
```

```bash
# add repo for postgres-operator
helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator

# install the postgres-operator
helm install postgres-operator postgres-operator-charts/postgres-operator
```

Now this cluster is ready to be used as a provider, lets get back to kcp terminal a workspace where we have provider:

```bash
kubectl ws use :root:providers
kubectl ws create postgres --enter
```

Lets create a placeholder APIExport:

```bash
kubectl create -f apis/export.yaml
```

Download API-Sync agent binary locally and run it:

TODO: Add binary publishing and downloads

```bash
./api-syncagent --namespace default --apiexport-ref acid.zalan.do --kcp-kubeconfig=$KCP_KUBECONFIG
```

Once this is done, we have postgres operator running in the provider cluster, and API-Sync agent making it 'shared' in the kcp cluster as service.

Lets create 2 consumers same way as we did with cowboys:

```bash
kubectl ws use :root:consumers
kubectl ws create pg-fan-boy --enter
kubectl kcp bind apiexport root:providers:postgres:acid.zalan.do acid.zalan.do 
```

Create a database instance:

```bash
kubectl create -f apis/consumer-1-database.yaml
```
