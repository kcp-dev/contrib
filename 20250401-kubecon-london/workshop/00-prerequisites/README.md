---
title: "00: Setting up your development environment"
---
# Pre-requisites

In this chapter we'll set up our workshop-dedicated development environment.

## Cloning the workshop repo

Start by cloning the git repository we'll refer to throughout the workshop, and will be the place for the binaries, scripts and kubeconfigs we will create as we move forward.

**Important:** We will need 4 terminal windows for long running programs & interactions to the same underlying machine during this workshop.

```shell
git clone https://github.com/kcp-dev/contrib.git kcp-contrib
cd kcp-contrib/20250401-kubecon-london/workshop
```

Now, let's see what's inside.

* `00-prerequisites/`
* `01-deploy-kcp/`
* `02-explore-workspaces/`
* `03-dynamic-providers/`
* `clean-all.sh`

Notice the exercises in directories `<Sequence number>-<Exercise name>`. These are the rules:

1. exercises need to be visited in sequence. To complete one, all previous exercises need to be completed first.
2. Are you stuck? While it's best if you try to follow the tasks by yourself, if you ever get stuck, you can finish an exercise by running the scripts inside the respective exercise directory.
3. Something broke? If you ever need to reset, run `clean-all.sh` to clean up.
4. Finished an exercise? High-five! Each exercise directory has a script `99-highfive.sh`. Run it to check-in your progress!

## Get your bins

Ready for a warm-up? In this quick exercise we are going to install programs we'll be using:

* [kcp](https://github.com/kcp-dev/kcp/releases/latest),
* kcp's [api-syncagent](https://github.com/kcp-dev/api-syncagent/releases/latest),
* kcp's [multicluster-controller runtime example binary](https://github.com/kcp-dev/contrib/releases/tag/v1-kubecon2025-london),
* [kind](https://github.com/kubernetes-sigs/kind/releases/latest),
* [kubectl](https://kubernetes.io/docs/tasks/tools/),
* and, [kubectl-krew](https://krew.sigs.k8s.io/docs/user-guide/setup/install/).

Install them all in one go by running the following script:

```shell
00-prerequisites/01-install.sh
```

Inspect it first, and you'll see that it `curl`s files from the GitHub releases of the respective project repositories, and stores them in `bin/`, inside our current working directory.

Alternatively, you may install the binaries manually. If you already have some of them installed and available in your `$PATH`, you may skip them--just make sure they are up-to-date. If you choose to go the manual way, please make sure the file names are stripped of any OS and arch names they may contain (e.g. `mv kubectl-krew-linux_amd64 kubectl-krew`), as we'll refer to them using their system-agnostic names later on.

And that's it!

---

## High-five! 🚀🚀🚀

Done already? High-five! Check-in your completion with:

```shell
00-prerequisites/99-highfive.sh
```

If there were no errors, you may continue with [the next exercise 🔥](/contrib/learning/20250401-kubecon-london/workshop/01-deploy-kcp/)!
