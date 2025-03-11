---
title: "00: Setting up your development environment"
---
# Pre-requisites

In this chapter we'll set up our workshop-dedicated development environment.

## Cloning the workshop repo

Start by cloning the git repository we'll refer to throughout the workshop, and will be the place for the binaries, scripts and kubeconfigs we will create as we move forward.

```shell
git clone git@github.com:mjudeikis/kcp-contrib.git
```

Now, let's see what's inside.

* `00-prerequisites/`
* `01-deploy-kcp/`
* `02-explore-workspaces/`
* `03-dynamic-providers/`
* `clean-all.sh`

Notice the exercises in directories `<Sequence number>-<Exercise name>`. These are to be visited in sequence, and to complete one, all previous exercises need to be completed first to bring the system into the desired state. While it's best if you try to follow the tasks by yourself, if you ever get stuck, you can finish an exercise by running the scripts inside the respective exercise directory.

Also take a note of the `clean-all.sh` script. If you ever get stuck and want to reset, run it and it will clean up and stop processes and containers used in the exercises.

## Get your bins

This one is easy. During the workshop we will make use of these programs:

* [kcp](https://github.com/kcp-dev/kcp/releases/latest),
* kcp's [api-syncagent](https://github.com/kcp-dev/api-syncagent/releases/latest),
* [kind](https://github.com/kubernetes-sigs/kind/releases/latest),
* [kubectl](https://kubernetes.io/docs/tasks/tools/),
* and, [kubectl-krew](https://krew.sigs.k8s.io/docs/user-guide/setup/install/).

You may visit the links, download and extract the respective binaries to a new directory called `bin/` in the workshop's root (e.g., `$WORKSHOP/bin/kubectl`). If you already have some of these installed and available in your `$PATH`, you may skip them--just make sure they are up-to-date.

Alternatively, we've prepared a script that does just that:

```shell
00-prerequisites/01-install.sh
```

If you're going the manual way, please make sure the file names are stripped of OS and arch names they may contain (e.g. `mv kubectl-krew-linux_amd64 kubectl-krew`), as we'll refer to them using their system-agnostic names later on.

And that's it!

---

## High-five! 🚀🚀🚀

Done already? High-five! Check-in your completion with:

```shell
00-prerequisites/99-highfive.sh
```

If there were no errors, you may continue with the next exercise.
