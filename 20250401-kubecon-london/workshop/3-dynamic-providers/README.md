# Dyanmic providers 

In this section we will explore dynamic providers, and how they can be used to create shared resources.

Lets prepare the kind cluster which will act as provider:

```bash
kind create cluster --name provider
```

```bash
kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.25/releases/cnpg-1.25.1.yaml
```

Now this cluster is ready to be used as a provider, lets get back to kcp terminal a workspace where we have provider:

```bash
kubectl ws use :root:providers
kubectl ws create database --enter
```

Lets create a placeholder APIExport:

```bash
kubectl create -f apis/export.yaml
```

Download API-Sync agent binary locally and run it:

TODO: Add binary publishing and downloads

```bash
./api-syncagent --namespace default --apiexport-ref postgresql.cnpg.io --kcp-kubeconfig=$KCP_KUBECONFIG
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

Create a database instance:

```bash
kubectl create -f apis/consumer-1-database.yaml
```

k ws use :root:providers:database
 ./api-syncagent --namespace default --apiexport-ref postgresql.cnpg.io --kcp-kubeconfig=$KCP_KUBECONFIG


 k ws use :root:consumers:pg-fan-boy