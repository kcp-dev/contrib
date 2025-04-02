---
title: "Introduction"
---
# KubeCon 2025 London: kcp workshop

We wish to welcome you to KubeCon 2025 London, at kcp's workshop titled _Exploring Multi-Tenant Kubernetes APIs and Controllers with kcp!_

While Kubernetes transformed container orchestration, creating multi-tenant platforms remains a significant challenge. kcp goes beyond DevOps and workload management, to reimagine how we deliver true SaaS experiences for platform engineers. Think workspaces and multi-tenancy, not namespaces in a singular cluster. Think sharding and horizontal scaling, not overly large and hard to maintain deployments. With innovative approaches to well-established building blocks in Kubernetes API-Machinery, **this CNCF sandbox project gives you a framework to _host and consume any kind of API_ you need to support your platforms.**

In this hands-on workshop, you will learn how to extend Kubernetes with kcp, build APIs, and design controllers to tackle multi-tenancy challenges. By exploring real-world scenarios like DBaaS across clusters, you will gain practical skills to create scalable, multi-tenant platforms.

* [www.kcp.io](https://www.kcp.io/)
* [github.com/kcp-dev/kcp](https://github.com/kcp-dev/kcp)

## Session outline

1. **Introduction.** Together we'll see what SaaS means in the context of Kubernetes, and how kcp plays a key role in enabling platform engineers and developers to build such SaaS platforms.
2. **Exploration.** We’ll get familiar with basic kcp concepts.
3. **Demonstration.** We’ll walk through practical examples and guide you through the prepared exercises.
4. **Execution.** Together, we’ll put everything we’ve learnt into action and build a tiny DBaaS platform—right on your PC!

The examples will touch on hosting and consuming SaaS-like APIs we'll create during the session: self-servicing databases to be used in a web-app platform.

## Before we begin

Before we begin, we needed to make a few assumptions about your PC and its environment:

* Your **amd64** or **arm64** PC is running recent **Linux with systemd** or **MacOS**; alternatively you may use [**GitHub Codespaces**](https://github.dev/kcp-dev/contrib) or [**Google Cloud Console**](https://console.cloud.google.com/).
* We are also expecting you have installed [Docker](https://www.docker.com/) or [podman](https://podman.io/), and [git](https://git-scm.com/); if not, please do it now.

**For attendees at the conference:** to minimize variance between everyone's work environments, thank you for preferring [**GitHub Codespaces**](https://github.dev/kcp-dev/contrib) or [**Google Cloud Console**](https://console.cloud.google.com/)!

All the tools and services we'll present during this workshop are local-installation only, don't require super-user privileges, and won't make permanent changes to your system.

## Starting out

Once ready, start by heading over to the first warm-up exercise: [`00-prerequisites` 🔥](/contrib/learning/20250401-kubecon-london/workshop/00-prerequisites/)!
