---
title: "03: Dynamic providers"
---

# Dynamic providers

In this exercise we'll explore an actual SaaS scenario: self-provisioning PostgreSQL databases, where:
* one (external) cluster will be in the role of a service owner, running the database servers,
* one workspace will be in the role of a service provider, where consumers can self-service their databases,
* one or more workspacess will be consuming the database(s).

Excited? Let's get down to it!

## Herding databases 🐑🐑🐑

!!! Important

    === "Bash/ZSH"

        ```shell
        export WORKSHOP_ROOT="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop"
        export EXERCISE_DIR="${WORKSHOP_ROOT}/03-dynamic-providers"
        export KUBECONFIGS_DIR="${WORKSHOP_ROOT}/kubeconfigs"
        export KREW_ROOT="${WORKSHOP_ROOT}/bin/.krew"
        export PATH="${WORKSHOP_ROOT}/bin/.krew/bin:${WORKSHOP_ROOT}/bin:${PATH}"
        ```

    === "Fish"

        ```fish
        set -gx WORKSHOP_ROOT (git rev-parse --show-toplevel)/20250401-kubecon-london/workshop
        set -gx EXERCISE_DIR $WORKSHOP_ROOT/03-dynamic-providers
        set -gx KUBECONFIGS_DIR $WORKSHOP_ROOT/kubeconfigs
        set -gx KREW_ROOT $WORKSHOP_ROOT/bin/.krew
        set -gx PATH $WORKSHOP_ROOT/bin/.krew/bin $WORKSHOP_ROOT/bin $PATH"
        ```

Surprise! You've just been appointed as the owner of a company responsible for running PostgreSQL databases, **SQL<sup>3</sup> Co.**! What's worse, you haven't heard of kcp yet! What you did hear of though is that PostgreSQL servers need compute and storage. And that Kubernetes can do all of that. So, to get things going, let's start up a [kind](https://kind.sigs.k8s.io/)-backed Kubernetes cluster:

!!! info "Creating a kind cluster"

    === "Docker"

        ```shell
        kind create cluster --name provider --kubeconfig $KUBECONFIGS_DIR/provider.kubeconfig
        ```

    === "podman"

        ```shell
        kind create cluster --name provider --kubeconfig $KUBECONFIGS_DIR/provider.kubeconfig
        ```

        If that doesn't work (error `running kind with rootless provider requires setting systemd property "Delegate=yes"`), try running the following command instead:

        ```shell
        systemd-run --user --scope \
          --unit="workshop-kcp-kind.scope" \
          --property=Delegate=yes \
          kind create cluster --name provider --kubeconfig $KUBECONFIGS_DIR/provider.kubeconfig
        ```

        See the following links for details: <https://kind.sigs.k8s.io/docs/user/rootless/> and <https://lists.fedoraproject.org/archives/list/devel@lists.fedoraproject.org/thread/ZMKLS7SHMRJLJ57NZCYPBAQ3UOYULV65/>.

Once the cluster is created, you can verify it's working with kubectl:

```shell
$ KUBECONFIG=$KUBECONFIGS_DIR/provider.kubeconfig kubectl version
Client Version: v1.32.2
Kustomize Version: v5.5.0
Server Version: v1.32.2
```

Success all around, let's deploy the [CloudNative PG](https://cloudnative-pg.io/)--the Kubernetes PostgreSQL operator:

```shell
KUBECONFIG=$KUBECONFIGS_DIR/provider.kubeconfig kubectl apply --server-side -f \
    https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.25/releases/cnpg-1.25.1.yaml
```

While its Pods are starting up, let's move onto the next step.

## Give and take

Whew, we're back in kcp land! Equipped with the knowledge from our last exercise, we already know that we can model producer-consumer relationship as workspaces, where one provides an APIExport (that exposes some API described by an APIResourceSchema or a CRD for example), and the other "imports" it by binding to it, with an APIBinding.

!!! Important

    === "Bash/ZSH"

        ```shell
        cp ${KUBECONFIGS_DIR}/admin.kubeconfig ${KUBECONFIGS_DIR}/sync-agent.kubeconfig
        export KUBECONFIG="${KUBECONFIGS_DIR}/sync-agent.kubeconfig"
        ```

    === "Fish"

        ```fish
        cp $KUBECONFIGS_DIR/admin.kubeconfig $KUBECONFIGS_DIR/sync-agent.kubeconfig
        set -gx KUBECONFIG $KUBECONFIGS_DIR/sync-agent.kubeconfig
        ```

What a strange thing we just did with that kubeconfig, don't you think? While important, we will come back to it later, in the next section. For now, let's focus on creating the provider's workspace, and an APIExport in it. We already have `:root:providers` workspace created, from where we provisioned Cowboys. While not very useful, we now know the commands to move around in the hierarchy of workspaces, and can create them too! Let's do that, this time for databases:

```shell
kubectl ws use :root:providers
kubectl ws create database --enter
```

The definition of the APIExport is already prepared for us in `$EXERCISE_DIR/apis/export.yaml`:

```shell
kubectl apply -f $EXERCISE_DIR/apis/export.yaml
```

If you're curious, you may go ahead and inspect the file and/or the object that was just created, and you'll notice that it's rather empty. As we continue forward, we'll see it populate with actual pgsql database specs and statuses. For now, let's create an equally empty APIBinding, to match our empty APIExport:

!!! Important

    === "Bash/ZSH"

        ```shell
        export KUBECONFIG="${KUBECONFIGS_DIR}/admin.kubeconfig"
        ```

    === "Fish"

        ```fish
        set -gx KUBECONFIG $KUBECONFIGS_DIR/admin.kubeconfig
        ```

```shell
kubectl ws :root:consumers
kubectl ws create pg --enter
kubectl kcp bind apiexport root:providers:database:postgresql.cnpg.io --accept-permission-claim secrets.core,namespaces.core
```

We've created a workspace `:root:consumers:pg`. The APIExport needs permissions to secrets, as it will store the authentication credentials for the databases we'll create, hence the permission claim flag.

With all that done, we're ready to _connect the dots:_ the external cluster running the pgsql servers, the provider workspace exposing the _postgresql.cnpg.io_ APIs, and the consumer workspace self-provisioning the pgsql servers and databases.

## Connect the dots

In the last exercise we discussed how there is nothing to reconcile Cowboys between workspaces, and that we'd need a controller that is able to observe state globally, react on Spec changes and update Status of the watched objects. Moreover, we need not only synchronizing APIs and objects across workspaces, but also across an external Kubernetes cluster that we've created above.

To do all of that, kcp offers one implementation of such a controller, the [api-syncagent](https://github.com/kcp-dev/api-syncagent). The api-syncagent generally runs in the cluster owning the service, i.e. our kind cluster. Then, the service owner would publish the API groups that are to be exposed to kcp--this is done by defining a PublishedResource object which we'll see in a bit. The published resources are then picked up by the api-syncagent, creating APIResourceSchemas for them automatically, and shoving them into the prepared APIExport on the kcp side, making them ready for consumption. There is a lot more going on, and you can consult the [project's documentation](https://github.com/kcp-dev/api-syncagent/tree/main/docs). But for now, this brief introduction shall suffice and we can move onto incorporating the controller into our seedling infrastructure.

!!! Important

    === "Bash/ZSH"

        ```shell
        export KUBECONFIG="${KUBECONFIGS_DIR}/provider.kubeconfig"
        ```

    === "Fish"

        ```fish
        set -gx KUBECONFIG $KUBECONFIGS_DIR/provider.kubeconfig
        ```

```shell
kubectl apply --server-side -f https://raw.githubusercontent.com/kcp-dev/api-syncagent/refs/heads/main/deploy/crd/kcp.io/syncagent.kcp.io_publishedresources.yaml
kubectl apply -f $EXERCISE_DIR/apis/resources-cluster.yaml
kubectl apply -f $EXERCISE_DIR/apis/resources-database.yaml
```

We've created PublishedResource objects for `clusters` and `databases` resources of the `postgresql.cnpg.io` API group. Give yourself a second and check the definitions we've just applyied. Take a look at the `publish-cnpg-cluster` PublishedResource, and you'll notice that it's not publishing just the pgsql Cluster, but also a Secret:

```yaml
  # ... snip ...
  related:
  - kind: Secret
    origin: kcp
    identifier: credentials
    reference:
      name:
        path: "spec.superuserSecret.name"
```

Currently in the role of a service owner, we know that pgsql (and specifically cnpg) stores credentials to the database server in a Secret, and that the secret is referenced by the `cluster` resource in its `spec.superuserSecret.name` field. The api-syncagent will extract that object using the path we supplied, and share it along with the `cluster` resource in the APIExport.

And that's it! The only thing left for us to do is to run the controller itself. api-syncagent can be deployed inside the cluster, or run externally as a standalone process. To make things simpler, we are going with the latter option:

```shell
api-syncagent --namespace default --apiexport-ref postgresql.cnpg.io --kcp-kubeconfig=$KUBECONFIGS_DIR/sync-agent.kubeconfig
```

At this point we have 2 shells running long running operations. Let's open 3rd one.

!!! Important

    === "Bash/ZSH"

        ```shell
        export WORKSHOP_ROOT="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop"
        export EXERCISE_DIR="${WORKSHOP_ROOT}/03-dynamic-providers"
        export KUBECONFIGS_DIR="${WORKSHOP_ROOT}/kubeconfigs"
        export KREW_ROOT="${WORKSHOP_ROOT}/bin/.krew"
        export PATH="${WORKSHOP_ROOT}/bin/.krew/bin:${WORKSHOP_ROOT}/bin:${PATH}"
        export KUBECONFIG="${KUBECONFIGS_DIR}/admin.kubeconfig"
        ```

    === "Fish"

        ```fish
        set -gx WORKSHOP_ROOT (git rev-parse --show-toplevel)/20250401-kubecon-london/workshop
        set -gx EXERCISE_DIR $WORKSHOP_ROOT/03-dynamic-providers
        set -gx KUBECONFIGS_DIR $WORKSHOP_ROOT/kubeconfigs
        set -gx KREW_ROOT $WORKSHOP_ROOT/bin/.krew
        set -gx PATH $WORKSHOP_ROOT/bin/.krew/bin $WORKSHOP_ROOT/bin $PATH
        set -gx KUBECONFIG $KUBECONFIGS_DIR/admin.kubeconfig
        ```

At the very beginning of this exercise we've made a copy of `admin.kubeconfig` into `sync-agent.kubeconfig` and using that we've created the `:root:providers:database` workspace. If you are wondering how does api-syncagent know where it can find the prepared APIExport, this is how. The kubeconfig has its context set to that workspace's endpoint. Now, leave the controller running and let's go create some databases finally!

!!! tip "Bonus step"

    If you are curious what happened to our mostly empty APIExport and APIBinding objects from before, now would be the time to `KUBECONFIG=$KUBECONFIGS_DIR/admin.config kubectl get -o json` them in another terminal. Can you spot what's different?

## May I have some?

    === "Bash/ZSH"

        ```shell
        export KUBECONFIG="${KUBECONFIGS_DIR}/admin.kubeconfig"
        ```

    === "Fish"

        ```fish
        set -gx KUBECONFIG $KUBECONFIGS_DIR/admin.kubeconfig
        ```

```shell
kubectl ws use :root:consumers:pg
```

Bam! You've just been promoted to a consumer! You don't have an application to run yet, but you know it will need a database or two for sure. Things couldn't be easier, because your company closed a contract with **SQL<sup>3</sup> Co.**, and what's more, there is an APIBinding in your workspace, importing the _postgresql.cnpg.io_ APIs, ready to use.

```shell
kubectl apply -f $EXERCISE_DIR/apis/consumer-1-cluster.yaml
kubectl apply -f $EXERCISE_DIR/apis/consumer-1-database.yaml
```

It's important we wait for the resources to be ready before we continue:

```shell-session
# Notice that the pgsql cluster is still booting up:
$ kubectl get cluster
NAME   AGE   INSTANCES   READY   STATUS               PRIMARY
kcp    27s   1                   Setting up primary

... 1 to 5 minutes later ...

# This is what a healthy cluster status looks like:
$ kubectl get cluster
NAME   AGE   INSTANCES   READY   STATUS                     PRIMARY
kcp    50s   1           1       Cluster in healthy state   kcp-1
```

And just like that, we have a PostgreSQL server with a database, that somebody else is running. Try to follow the example below!

<div class="grid" markdown>

```shell-session title="Service owner"
$ export KUBECONFIG=$KUBECONFIGS_DIR/provider.kubeconfig
$ kubectl get namespaces
1yaxsslokc5aoqme     Active   6m34s
cnpg-system          Active   10m
default              Active   10m
kube-node-lease      Active   10m
kube-public          Active   10m
kube-system          Active   10m
local-path-storage   Active   10m

$ kubectl -n 1yaxsslokc5aoqme get clusters
NAME   AGE     INSTANCES   READY   STATUS                     PRIMARY
kcp    7m46s   1           1       Cluster in healthy state   kcp-1
$ kubectl -n 1yaxsslokc5aoqme get databases
NAME     AGE    CLUSTER   PG NAME   APPLIED   MESSAGE
db-one   8m3s   kcp       one       true
```

```shell-session title="Service consumer"
$ export KUBECONFIG=$KUBECONFIGS_DIR/admin.kubeconfig
$ kubectl ws use :root:consumers:pg
Current workspace is 'root:consumers:pg' (type root:universal).

$ kubectl get databases
NAME     AGE     CLUSTER   PG NAME   APPLIED   MESSAGE
db-one   8m45s   kcp       one       true

$ kubectl get clusters
NAME   AGE     INSTANCES   READY   STATUS                     PRIMARY
kcp    8m51s   1           1       Cluster in healthy state   kcp-1

$ kubectl get secrets
NAME            TYPE                       DATA   AGE
kcp-postgres    kubernetes.io/basic-auth   2      9m3s
kcp-superuser   kubernetes.io/basic-auth   2      9m3s
```

</div>

Indeed, if you check the kcp side, you'll see that we have only one consumer `pg` with a single database instance in our workspace `root:consumers:pg`. Nothing stops us from creating more however. We are however going to limit ourselves to only one consumer during the workshop. Feel free to explore and create more consumers later yourself!

Now, what can we do with it? You may recall that there were Secrets involved in the permission claims when we bound the APIExport. As it turns out, we have a Secret with admin access to the PostgreSQL sever (as we should, we own it!), and can use it to authenticate.

> A side note: we are going to cheat a bit now. We are running all the clusters on the same machine, and we know what IPs and ports to use. Having the username and the password to the DB is one thing, knowing where to connect is another. In the real world, **SQL<sup>3</sup> Co.** would have created a proper Ingress with a Service for us, and generated a connection string inside a Secret, and this would all work as it stands. Not having done that though, let's agree on a simplification: in place of ingress we will use port-forwarding, and the connection string we will create ourselves.

<div class="grid" markdown>

```shell-session title="port forward"
$ export KUBECONFIG=$KUBECONFIGS_DIR/provider.kubeconfig
$ # Pretending to have an Ingress by port-forwarding in a separate terminal.
$ # Note that the "kcp-rw" service is created by the cnpg operator, and that the "kcp" in the name comes from the PostgreSQL cluster name.
$ kubectl -n 1yaxsslokc5aoqme port-forward svc/kcp-rw 5432:5432
Forwarding from 127.0.0.1:5432 -> 5432
Forwarding from [::1]:5432 -> 5432
Handling connection for 5432
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080
```

```shell-session title="psql client"
$ export KUBECONFIG=$KUBECONFIGS_DIR/admin.kubeconfig
$ export pg_username="$(kubectl get secret kcp-superuser -o jsonpath='{.data.username}' | base64 -d)"
$ export pg_password="$(kubectl get secret kcp-superuser -o jsonpath='{.data.password}' | base64 -d)"
$ docker run -it --rm --network=host --env PGPASSWORD=$pg_password postgres psql -h 127.0.0.1 -d one -U postgres
psql (17.4 (Debian 17.4-1.pgdg120+2))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off, ALPN: postgresql)
Type "help" for help.

one=# SELECT * FROM pg_catalog.pg_tables WHERE schemaname = 'pg_catalog';
 schemaname |        tablename         | tableowner | tablespace | hasindexes | hasrules | hastriggers | rowsecurity
------------+--------------------------+------------+------------+------------+----------+-------------+-------------
 pg_catalog | pg_statistic             | postgres   |            | t          | f        | f           | f
 pg_catalog | pg_type                  | postgres   |            | t          | f        | f           | f
...
```

</div>

How cool is that!

In this exercise we've seen multiple personas interacting with each other, and each having different responsibilities. This is what Software-as-a-Service style of workflow can look like. Want more? In the next, and final exercise of this workshop, we'll explore what it's like to develop and deploy mutli-cluster applications against kcp.

---

## High-five! 🚀🚀🚀

Finished? High-five! Check-in your completion with:

```shell
03-dynamic-providers/99-highfive.sh
```

If there were no errors, you may continue with the next exercise.

### Cheat-sheet

You may fast-forward through this exercise by running:
* `03-dynamic-providers/00-run-provider-cluster.sh`
* `03-dynamic-providers/01-deploy-postgres.sh`
* `03-dynamic-providers/02-create-provider.sh`
* `03-dynamic-providers/03-create-consumer.sh`
* `03-dynamic-providers/04-run-api-syncagent.sh` in a separate terminal
* `03-dynamic-providers/05-create-database.sh`
* `03-dynamic-providers/99-highfive.sh`
