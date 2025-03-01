# Run KCP the easy way

Easy way means we just use standalone binary to run kcp. Simple as that.

Download binary:

```bash
./downloadsh.sh
```

Run kcp:

```bash
./start.sh
```

In separete terminal window:

```bash
export KUBECONFIG=.kcp/admin.kubeconfig
kubectl api-resources
```

