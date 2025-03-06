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

Leave it running. We will have it running in the background during all the workshop.
In separete terminal window, set kubeconfig to kcp control plane kubeconfig.
This will be our main terminal window for the workshop to interact with kcp.

```bash
export KUBECONFIG=.kcp/admin.kubeconfig
kubectl api-resources
```

