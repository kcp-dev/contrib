---
title: "01: Deploying kcp"
---
# Deploy kcp

kcp may be deployed via a [Helm chart](https://github.com/kcp-dev/helm-charts), an [operator](https://github.com/kcp-dev/helm-charts), or as a standalone process running on the host. Each of them has its uses as well as advantages and disadvantages. While the most preferable way to deploy kcp is using its dedicated operator, for the sake of simplicity, we've taken the liberty of making the choice for you :) .

## Starting kcp as a standalone process

!!! Important

    **Attention**: during these exercises, we'll be making heavy use of environment variables. We will be switching back and forth between clusters, as well as needing access to the binaries we've set up in the previous chapter. Whenever you see this block, it means we are switching an environment. Make sure you `cd` into the workshop git repo, and copy-paste the commands to your terminal. Let's give it a try!


!!! Important

    === "Bash/ZSH"

        ```shell
        export WORKSHOP_ROOT="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop"
        export PATH="${WORKSHOP_ROOT}/bin:${PATH}"
        ```

    === "Fish"

        ```fish
        set WORKSHOP_ROOT (git rev-parse --show-toplevel)/20250401-kubecon-london/workshop
        set PATH $WORKSHOP_ROOT/bin $PATH
        ```

Starting kcp in standalone mode is as easy as typing `kcp start` and pressing Enter.

```shell
cd $WORKSHOP_ROOT && kcp start
```


You should see the program running indefinitely, and outputting its logs--starting with some errors that should clean up in a couple of seconds as the different controllers start up. Leave the terminal window open, as we will keep using this kcp instance throughout the duration of the workshop. In this mode, all kcp's state is in-memory only. That means exiting the process (by, for example, pressing _Ctrl+C_ in this terminal), will lose all its etcd contents.

Once kcp's output seems stable, we can start making simple kubectl calls against it. `kcp start` creates a hidden directory `.kcp`, where it places its kubeconfig and the certificates.

Open a new terminal (termianl 2, same 01-deploy-kcp directory) now.

!!! Important

    === "Bash/ZSH"

        ```shell
        export WORKSHOP_ROOT="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop"
        export KUBECONFIG="${WORKSHOP_ROOT}/.kcp/admin.kubeconfig"
        ```

    === "Fish"

        ```fish
        set WORKSHOP_ROOT (git rev-parse --show-toplevel)/20250401-kubecon-london/workshop
        set KUBECONFIG $WORKSHOP_ROOT/.kcp/admin.kubeconfig"
        ```

The following command should work now:

```shell-session
$ kubectl version
Client Version: v1.32.1
Kustomize Version: v5.5.0
Server Version: v1.31.0+kcp-v0.26.1
```

We'll have a couple more kubeconfigs to switch between, and it will be convenient to have them all in one place. Let's do that now:

```shell
mkdir -p $WORKSHOP_ROOT/kubeconfigs
ln -s $KUBECONFIG $WORKSHOP_ROOT/kubeconfigs
```

And that's it!

---

## High-five! 🚀🚀🚀

Finished? High-five! Check-in your completion with:

```shell
01-deploy-kcp/99-highfive.sh
```

If there were no errors, you may continue with the next exercise.

### Cheat-sheet

You may fast-forward through this exercise by running:
* `01-deploy-kcp/01-start-kcp.sh` in a new terminal
