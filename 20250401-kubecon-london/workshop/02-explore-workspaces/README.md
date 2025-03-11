---
title: "02: Exploring workspaces"
---
# Explore workspaces

Workspaces are one of kcp's core concepts, and in this exercise we'll explore what they are and how to work with them.

See Workspaces documentation at [docs.kcp.io/kcp/main/concepts/workspaces/](https://docs.kcp.io/kcp/main/concepts/workspaces/).

## Pre-requisites, take two

Workspaces, or kcp for that matter, is not something that vanilla kubectl knows about. kcp brings support for those using [krew](https://krew.sigs.k8s.io/) plugins. You may remember, we installed kubect-krew in the very first warm-up exercise. Now we need to install the plugins themselves:

!!! Important

    === "Bash/ZSH"

        ```shell
        export WORKSHOP_ROOT="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop-"
        export KREW_ROOT="${workshop_root}/bin/.krew"
        export PATH="${WORKSHOP_ROOT}/bin/.krew/bin:${WORKSHOP_ROOT}/bin:${PATH}"
        ```

    === "Fish"

        ```fish
        set -gx WORKSHOP_ROOT (git rev-parse --show-toplevel)/20250401-kubecon-london/workshop-
        set -gx KREW_ROOT $WORKSHOP_ROOT/bin/.krew
        set -gx PATH $WORKSHOP_ROOT/bin/.krew/bin $WORKSHOP_ROOT/bin $PATH"
        ```

```shell
kubectl krew index add kcp-dev https://github.com/kcp-dev/krew-index.git
kubectl krew install kcp-dev/kcp
kubectl krew install kcp-dev/ws
kubectl krew install kcp-dev/create-workspace
```

Now you should be able to run and inspect these commands:
```shell-session
$ kubectl create workspace --help
Creates a new workspace

Usage:
  create [flags]
...

$ kubectl ws --help
Manages KCP workspaces

Usage:
  workspace [create|create-context|use|current|<workspace>|..|.|-|~|<root:absolute:workspace>] [flags]
  workspace [command]
...

$ kubectl kcp --help
...
```

With that, let's create some workspaces!

## Sprawling workspaces

!!! Important

    === "Bash/ZSH"

        ```shell
        export WORKSHOP_ROOT="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop-"
        export KREW_ROOT="${WORKSHOP_ROOT}/bin/.krew"
        export PATH="${workshop_root}/bin/.krew/bin:${workshop_root}/bin:${PATH}"
        ```

    === "Fish"

        ```fish
        set -gx WORKSHOP_ROOT (git rev-parse --show-toplevel)/20250401-kubecon-london/workshop-
        set -gx KREW_ROOT $WORKSHOP_ROOT/bin/.krew
        set -gx PATH $WORKSHOP_ROOT/bin/.krew/bin $WORKSHOP_ROOT/bin $PATH"
        ```

We'll be using `kubectl create workspace` command:

```shell
kubectl create workspace one
kubectl create workspace two
kubectl create workspace three --enter
kubectl create workspace potato
```

Now, let's list what we've created:

```shell
kubectl ws use :
kubectl get ws
```

These are the workspaces we created, and they represent logical separation of resources in the cluster.

We haven't seen `ws use` yet. Using this command, you move into a different workspace in the tree of workspaces, much like `cd` moves you into a different directory described by a path. In case of workspaces, a path too may be relative or absolute, where `:` is the path separator, and `:` alone denotes the root of the tree.

```shell
kubectl ws use :
kubectl ws use one
kubectl get configmap
kubectl create configmap test --from-literal=test=one
kubectl get configmap test -o json
```

```shell
kubectl ws use root:two
kubectl get configmap
kubectl create configmap test --from-literal=test=two
kubectl get configmap test -o json
```

Notice how even though these two ConfigMaps have the same name `test`, and are in the same namespace `default`, they are actually two distinct objects. They live in two different workspaces, and are completely separate.

We've created a few workspaces now, and already it's easy to lose sight of what is where. Say hello to `ws tree`:

```shell
kubectl ws use :
kubectl ws tree
```

You should get output similar to this:

```
.
└── root
    ├── one
    ├── three
    │   └── potato
    └── two
```

## Exporting and binding APIs across workspaces

Isolation is nice, but what if you need to _share?_

See [docs.kcp.io/kcp/main/concepts/apis/exporting-apis/](https://docs.kcp.io/kcp/main/concepts/apis/exporting-apis/) for detailed documentation.

As you'll see next, _sharing_ in this context will be a very well-defined and constrained relationship of provisioning and consuming. We shall model that relationship using workspaces.

### Service provider

Create `providers` and `providers:cowboys` workspaces:

```shell
kubectl ws use :
kubectl ws create providers --enter
kubectl ws create cowboys --enter
```

```shell-session
$ kubectl ws use :
Current workspace is 'root'.
$ kubectl ws tree
.
└── root
    ├── one
    ├── providers
    │   └── cowboys
    ├── three
    │   └── potato
    └── two

$ kubectl ws use :root:providers:cowboys
Current workspace is 'root:providers:cowboys' (type root:universal).
```

Now that we're in `:root:providers:cowboys`, let's create an `APIResourceSchema` and an `APIExport`. We'll discuss what are they for next.

```shell
kubectl create -f $WORKSHOP_ROOT/02-explore-workspaces/apis/apiresourceschema.yaml
kubectl create -f $WORKSHOP_ROOT/02-explore-workspaces/apis/apiexport.yaml
```

Starting with the first one, `APIResourceSchema`:

```shell
kubectl get apiresourceschema -o json
```

Try to skim through the YAML output and you'll notice that it is almost identical to a definition of a CRD. Unlinke a CRD however, `APIResourceSchema` instance does not have a backing API server, and instead it simply describes an API that we can pass around and refer to. By decoupling the schema definition from serving, API owners can be more explicit about API evolution.

```shell
kubectl get apiexport cowboys -o yaml
```

Take a note of the following properties in the output:
* `.spec.latestResourceSchemas`: refers to specific versions of `APIResourceSchema` objects,
* `.spec.permissionClaims`: describes resource permissions that our API depends on. These are the permissions that we, the service provider, want the consumer to grant us,
* `.status.virtualWorkspaces[].url`: the URL where the provider can access the granted resources.
```yaml
# Stripped down example output of `kubectl get apiexport` command above.
spec:
  latestResourceSchemas:
  - today.cowboys.wildwest.dev
  permissionClaims:
  - all: true
    group: ""
    resource: configmaps
status:
  virtualWorkspaces:
  - url: https://192.168.32.7:6443/services/apiexport/1ctnpog1ny8bnud6/cowboys
```

### Service consumer

With the provider in place, let's create two consumers in their own workspaces, starting with "wild-west":

```shell
kubectl ws use :
kubectl create workspace consumers --enter
kubectl create workspace wild-west --enter
kubectl kcp bind apiexport root:providers:cowboys:cowboys --name cowboys-consumer
kubectl create -f $WORKSHOP_ROOT/02-explore-workspaces/apis/consumer-wild-west.yaml
```

Let's check the Cowboy we have created:

```shell-session
$ kubectl get cowboy buckaroo-bill -o json
{
    "apiVersion": "wildwest.dev/v1alpha1",
    "kind": "Cowboy",
    "metadata": {
        "annotations": {
            "kcp.io/cluster": "2snrfbp1a3gww1hu"
        },
        "creationTimestamp": "2025-03-12T09:06:53Z",
        "generation": 1,
        "name": "buckaroo-bill",
        "namespace": "default",
        "resourceVersion": "3164",
        "uid": "bb6ece46-84bc-4673-a926-f38c486799cf"
    },
    "spec": {
        "intent": "Ride and protect the wild west!!!"
    }
}
```

And the second consumer, "wild-north":

```shell
kubectl ws use ..
kubectl create workspace wild-north --enter
kubectl kcp bind apiexport root:providers:cowboys:cowboys --name cowboys-consumer
kubectl create -f $WORKSHOP_ROOT/02-explore-workspaces/apis/consumer-wild-north.yaml
```

```shell-session
$ kubectl get cowboy hold-the-wall -o json
{
    "apiVersion": "wildwest.dev/v1alpha1",
    "kind": "Cowboy",
    "metadata": {
        "annotations": {
            "kcp.io/cluster": "30j93qa92345q3tp"
        },
        "creationTimestamp": "2025-03-12T09:09:32Z",
        "generation": 1,
        "name": "hold-the-wall",
        "namespace": "default",
        "resourceVersion": "3227",
        "uid": "ff96ab88-b738-4af7-8cc0-3872c424d9df"
    },
    "spec": {
        "intent": "North is there the wall is!"
    }
}
```

Great! We have created two instances of a common API, and were able to create a couple of dummy objects with it.

```shell-session
$ kubectl ws use :
Current workspace is 'root'.
$ kubectl ws tree
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

### Spec up, status down

We have been moving across namespaces up and down, changing our implied roles. Let's become the service provider again, and see what we can make out from our `cowboys` APIExport.

```shell
kubectl ws :root:providers:cowboys
kubectl get apiexport cowboys -o json | jq '.status.virtualWorkspaces[].url'
```

Using that URL, we can confirm that only the resources we have agreed on are available to the workspaces.

```shell-session
$ kubectl -s 'https://192.168.32.7:6443/services/apiexport/1ctnpog1ny8bnud6/cowboys/clusters/*' api-resources
NAME          SHORTNAMES   APIVERSION              NAMESPACED   KIND
configmaps                 v1                      true         ConfigMap
apibindings                apis.kcp.io/v1alpha1    false        APIBinding
cowboys                    wildwest.dev/v1alpha1   true         Cowboy
```

We can also list all consumers (i.e. workspaces that have relevant `APIBinding`) for cowboys `APIExport`:

```shell-session
$ kubectl -s 'https://192.168.32.7:6443/services/apiexport/1ctnpog1ny8bnud6/cowboys/clusters/*' get cowboys -A
NAMESPACE   NAME
default     buckaroo-bill
default     hold-the-wall
```

You can play around with inspecting the json output of those commands, and try addressing a specific cluster instead of all of them (wildcard `*`) to get some intuition about how they are wired together.

From that, you can already start imagining what a workspace-aware controller operating on these objects would look like: being able to observe global state in its workspace subtree, it would watch spec updates from its children (Spec up), and push them status updates (Status down). Our basic example is lacking such a controller. But that's something we are going to fix the next exercise, on a more interesting example!

---

## High-five! 🚀🚀🚀

Finished? High-five! Check-in your completion with:

```shell
../02-explore-workspaces/99-highfive.sh
```

If there were no errors, you may continue with the next exercise.

### Cheat-sheet

You may fast-forward through this exercise by running:
* `02-explore-workspaces/00-install-krew-plugins.sh`
* `02-explore-workspaces/01-create-apis.sh`
* `02-explore-workspaces/02-create-consumers.sh`
* `02-explore-workspaces/99-highfive.sh`
