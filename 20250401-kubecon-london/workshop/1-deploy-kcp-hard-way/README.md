# Deploy kcp into kind

1. Install kind if you haven't already. You can find the instructions [here](https://kind.sigs.k8s.io/docs/user/quick-start/).

2. Install helm if you haven't already. You can find the instructions [here](https://helm.sh/docs/intro/install/).

3. Create a kind cluster with the following command:

```bash
kind create cluster --name kcp --config kind/cluster.yaml
```

4. Deploy ingress into the kind cluster and wait until its ready:

```bash
helm install ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx ingress-nginx \
    -f kind/ingress-helm.yaml \
    --create-namespace \
    --namespace ingress-nginx
```

5. Deploy cert-manager into the kind cluster:

```bash
helm repo add jetstack https://charts.jetstack.io

helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --version v1.10.0 \
    --set installCRDs=true \
    --create-namespace
```

6. Deploy etcd into the kind cluster:

```bash
helm install etcd oci://registry-1.docker.io/bitnamicharts/etcd --set auth.rbac.enabled=false --set auth.rbac.create=false
```

7. We will not use Helm to deploy operator as its not yet fully production ready. We gonna use native kubebuilder commands to deploy the operator.
   Clone the kcp-operator repository. We will use the latest version of the operator.

```bash
git clone https://github.com/kcp-dev/kcp-operator 
```

8. Deploy issuer for cert-manager:

```bash
kubectl apply -f ./kcp-operator/config/samples/cert-manager/issuer.yaml
```

9. Deploy the kcp operator into the kind cluster:
```
cd kcp-operator && make deploy
cd ..
```

10. Create a kcp instance object to deploy the kcp control plane:

```bash
kubectl apply -f kcp/v1alpha1_rootshard.yaml
kubectl apply -f kcp/v1alpha1_frontproxy.yaml
```

11. Verify that the kcp control plane is up and running. This may take a few minutes:

```bash
kubectl get pods -w
```

12. Create ingress:

```bash
kubectl apply -f kind/ingress.yaml
```

13. Create a request to get the kubeconfig for the kcp control plane:

```bash
kubectl apply -f kcp/v1alpha1_kubeconfig_admin.yaml
```

14. Get the kubeconfig for the kcp control plane:

```bash
kubectl get secret admin-kubeconfig -o jsonpath='{.data.kubeconfig}' | base64 --decode > kcp.kubeconfig  
```

16. Modify /etc/host or /private/etc/hosts file to add the following entry:

```bash
127.0.0.1 kcp.localhost
```

15. Set the KUBECONFIG environment variable to point to the kcp control plane kubeconfig:

```bash
export KUBECONFIG=kcp.kubeconfig
```