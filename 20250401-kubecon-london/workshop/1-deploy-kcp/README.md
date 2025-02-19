# Deploy kcp into kind

1. Install kind if you haven't already. You can find the instructions [here](https://kind.sigs.k8s.io/docs/user/quick-start/).

2. Install helm if you haven't already. You can find the instructions [here](https://helm.sh/docs/intro/install/).

3. Create a kind cluster with the following command:

```bash
kind create cluster --name kcp
```

4. Deploy cert-manager into the kind cluster:

```bash
helm repo add jetstack https://charts.jetstack.io

helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --version v1.10.0 \
    --set installCRDs=true \
    --create-namespace
```

5. Deploy etcd into the kind cluster:

```bash
helm install etcd oci://registry-1.docker.io/bitnamicharts/etcd \
        --set auth.rbac.enabled=false \
        --set auth.rbac.create=false \
        --namespace kcp-system \
        --create-namespace
```

6. Create Issuer for certiticates:

```bash
kubectl apply -f https://raw.githubusercontent.com/kcp-dev/kcp-operator/refs/heads/main/config/samples/cert-manager/issuer.yaml
```

4. Deploy kcp operator into the kind cluster:

TODO: replace the image tag with the latest one

```bash
helm repo add kcp https://kcp-dev.github.io/helm-charts

helm install kcp kcp/kcp-operator \
   --namespace kcp-system \
   --create-namespace \
   --set image.tag=main
```

5. Verify that the kcp operator is running:

```bash
kubectl get pods -n kcp-system
```

6. Create a kcp instance object to deploy the kcp control plane:

```bash
kubectl apply -f https://raw.githubusercontent.com/kcp-dev/kcp-operator/refs/heads/main/config/samples/v1alpha1_rootshard.yaml
```