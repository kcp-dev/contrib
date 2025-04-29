# Remote mounts virtual workspace example

This is an example of how to use the mounts feature in kcp to mount a target cluster into a workspace.
Mount happens at front-proxy level via reverse proxy. You need to implement your own VirtualWorkspace to handle this.
and this example shows how to do it.

## This is example codebase, and should be used only as example.

# Step by step guide

Step by step guide how to setup this example.

1. Start kcp with mounts feature gate enabled:

```
 go run ./cmd/kcp start --miniproxy-mapping-file=../contrib/20241013-kubecon-saltlakecity/mounts-vw/assets/path-mapping.yaml --feature-gates=WorkspaceMounts=true 
```

2. Setup all required workspaces and exports for virtual workspace to run:

Provider workspace where all the target cluster will be defined with secrets.
These clusters can be mounted later on by the any workspace.

Setup providers:

```
# Set kcp KUBECONFIG
export KUBECONFIG=../../../kcp/.kcp/admin.kubeconfig     

kubectl ws use :root
# create provider workspaces
kubectl ws create providers --enter
kubectl ws create mounts --enter

# create exports
kubectl create -f config/mounts/resources/apiresourceschema-targetkubeclusters.targets.contrib.kcp.io.yaml
kubectl create -f config/mounts/resources/apiresourceschema-kubeclusters.mounts.contrib.kcp.io.yaml
kubectl create -f config/mounts/resources/apiresourceschema-targetvclusters.targets.contrib.kcp.io.yaml
kubectl create -f config/mounts/resources/apiresourceschema-vclusters.mounts.contrib.kcp.io.yaml
kubectl create -f config/mounts/resources/apiexport-mounts.contrib.kcp.io.yaml
kubectl create -f config/mounts/resources/apiexport-targets.contrib.kcp.io.yaml

```

3. Start virtual workspace process:
```
 go run ./cmd/virtual-workspaces/ start \
 --kubeconfig=../../../kcp/.kcp/admin.kubeconfig      \
 --tls-cert-file=../../../kcp/.kcp/apiserver.crt \
 --tls-private-key-file=../../../kcp/.kcp/apiserver.key \
 --authentication-kubeconfig=../../../kcp/.kcp/admin.kubeconfig \
 --virtual-workspaces-proxy-hostname=https://localhost:6444 \
 -v=8
```

4. Continue bootstrapping the mounts example:

```
# create operators namespace where platforms operators will create objects. This could be many of them.
# for this example we will use only one.

kubectl ws use :root
kubectl ws create operators --enter
kubectl ws create mounts --enter

# bind the exports
kubectl kcp bind apiexport root:providers:mounts:targets.contrib.kcp.io  --accept-permission-claim secrets.core

# Create a target cluster to `kind` cluster locally:

# create kind cluster if not already created
kind create cluster --name kind --kubeconfig kind.kubeconfig

#create secret with kubeconfig:
kubectl ws use :root:operators:mounts
kubectl create secret generic kind-kubeconfig --from-file=kubeconfig=kind.kubeconfig

# create target cluster:
kubectl create -f config/mounts/resources/example-target-cluster.yaml

# create vcluster target:
kubectl create -f config/mounts/resources/example-target-vcluster.yaml

# get secret string:
kubectl get TargetKubeCluster proxy-cluster -o jsonpath='{.status.secretString}'
kTPlAYLMjKJDRly5

Nis8xbLPoqPUrapA%

kubectl get TargetVCluster proxy-cluster -o jsonpath='{.status.secretString}'
Nis8xbLPoqPUrapA

# Create a consumer workspace for mounts:
kubectl ws use :root
kubectl ws create consumer --enter

# This is not yet available in CLI
kubectlcreate -f config/mounts/resources/example-workspace-kind-cluster-mounted.yaml   

kubectl kcp bind apiexport root:providers:mounts:mounts.contrib.kcp.io 

# !!!!! replace secrets string first in the file bellow :
kubectl create -f config/mounts/resources/example-mount-cluster.yaml
```

5. Check the mounts reconciler logs:
Now workspace should be backed by mountpoint from front-proxy:

```
kubectl ws use kind-cluster
k get pods -A
NAMESPACE            NAME                                         READY   STATUS    RESTARTS   AGE
kube-system          coredns-7db6d8ff4d-4l625                     1/1     Running   0          22h
kube-system          coredns-7db6d8ff4d-ntf95                     1/1     Running   0          22h
kube-system          etcd-kind-control-plane                      1/1     Running   0          22h
kube-system          kindnet-vv872                                1/1     Running   0          22h
kube-system          kube-apiserver-kind-control-plane            1/1     Running   0          22h
kube-system          kube-controller-manager-kind-control-plane   1/1     Running   0          22h
kube-system          kube-proxy-lkv29                             1/1     Running   0          22h
kube-system          kube-scheduler-kind-control-plane            1/1     Running   0          22h
local-path-storage   local-path-provisioner-988d74bc-dqnd7        1/1     Running   0          22h
```

# Vclusters example

vCluster are backed by vCluster mounts. This is a way to create a virtual cluster that is backed by a real cluster.
You can either provide a kubeconfig or a target cluster to back the vCluster or secretString for "target" in the system.

kubectl create -f config/mounts/resources/example-workspace-vcluster-mounted.yaml

kubectl create -f config/mounts/resources/example-mount-vcluster.yaml

# Known issues

1. `TargetKubeCluster` changes do not propagate to `KubeCluster` need to wire them up.
Challenge is that when these 2 objects are in separate bindings, its more machinery to make them work together.

2. VirtualWorkspace is not yet fully shards aware. Ideally it should be 1 per each shard, and handle only its
own workspaces.

3. KubeCluster changes not applied to Workspaces. This might be a bug in core. Need to validate.

