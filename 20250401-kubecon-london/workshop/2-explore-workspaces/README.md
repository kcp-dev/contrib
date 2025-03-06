# Explore what's in the workspace

# Pre-requisite

* kcp is running in separate terminal windoes and kubeconfig is set to kcp control plane kubeconfig. 
* krew is installed https://krew.sigs.k8s.io/docs/user-guide/setup/install/

In this step, we will explore the workspace and see what's in it.

## Steps

Install `krew` kcp `plugin`

```bash 
kubectl krew index add kcp-dev https://github.com/kcp-dev/krew-index.git
kubectl krew install kcp-dev/kcp
kubectl krew install kcp-dev/ws
kubectl krew install kcp-dev/create-workspace
```

1. Source kubeconfig to part 2 from previous step:

```bash
source 1_config.sh
```

2. Create first workspaces

```bash
kubectl ws create one
kubectl ws create two
kubectl ws create three --enter
kubectl ws create potato
```

3. List workspaces

```bash
kubectl ws use :
kubectl get ws
```

These are the workspaces we created, and they represent logical separation of resources in the cluster. Explore the workspaces to see they are isolated from each other. 
Move between workspaces and see the resources in each workspace, try creating some:

Example:

```bash
kubectl ws use :
kubectl ws use one
kubectl get configmap
kubectl create configmap test --from-literal=test=one
kubectl get configmap
```

```bash
kubectl ws use root:two
kubectl get configmap
kubectl create configmap test --from-literal=test=two
kubectl get configmap
```

See that the resources are isolated from each other.
See worspace tree, this is your workspace hierarchy.

```bash
kubectl ws use :
kubectl ws tree
```

Explore a bit to see how you can move between workspaces, created nested workspaces, etc.
As we seen APIS which are not shared, lets create something "shared" (note the quotes)

```bash
./2_apis.sh
```

So lets explore what we have created:

```bash
kubectl ws use :
kubectl ws tree
```

We see workspace tree, and we see providers workspace with single provider workspace.

You should see view like this:
```
kubectl ws tree
Current workspace is 'root'.
.
└── root
    ├── one
    ├── providers
    │   └── cowboys
    ├── three
    │   └── potato
    └── two
```

Let's check what are the object we created:

```bash
kubectl ws use :root:providers:cowboys
kubectl get apiresourceschema -o yaml
```

`APIResourceSchema` is a custom resource which holds APIs in the form of CRD. 
This way we can inform kcp - this is an API I want to share.

Now APIExport is the object which is shared with the consumers. Let's see what we have created:

```bash
kubectl get apiexport cowboys -o yaml
```

We can see this export has few interesting things:
1. `Schema` - which is the schema we share
2. `PermissionClaims` - additional permissions we want to ask from consumer to give us.
3. `status.virtualWorkspaces[].url` - this is the URL where provider can access all the resources! We will come back to this!!!!

Now imagine we have 2 consumers of our cowboys apis. Inspect the script before running it.

```bash
./3_consumers.sh
```

Let's see what we have created:

```bash
kubectl ws use :
kubectl ws tree
```

You should see:
```
kubectl ws tree
Current workspace is 'root'.
.
└── root
    ├── consumers
    │   ├── wild-north
    │   └── wild-west
    ├── one
    ├── providers
    │   └── cowboys
    ├── three
    │   └── potato
    └── two
```

We have 2 cosumers, and as we seen in the beggining of this step, we have 2 workspaces, containing 2 cowboys and 2 instances of the same API. How does one now interact with them from provider side?

```bash
kubectl ws use :root:providers:cowboys
kubectl get apiexport cowboys -o yaml
```

Take the url of the APIExport and curl it to check what apis are available.

IMPORTANT: Replace the URL with the one you got from the previous command.

```bash
kubectl -s 'https://192.168.3.14:6443/services/apiexport/1i2moui67r1ychss/cowboys/clusters/*' api-resources
```

This should show you the resources available in the APIExport. From normal kubernetes clusters, its has way smaller list of resources, as we have shared only few of them.

Now lets see cowboy resources:

```bash
kubectl -s 'https://192.168.3.14:6443/services/apiexport/1i2moui67r1ychss/cowboys/clusters/*' get cowboys -A
```

This should return 2 cowboys, one from each consumer. Now there might be another resources in those workspaces, coming from different providers. Different providers would have access to only their "claimed" resources.

This concludes the exploration section of the worspaces. Lets see more complicated example in the next section.

Feel free to expore both consumers, create more of them, and see how isolation works.

One you get the hang of it, lets move to the next section.
