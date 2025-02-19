# KCP Workshop

## Description

While Kubernetes transformed container orchestration, creating multi-tenant platforms remains a significant challenge. kcp goes beyond DevOps and workload management, to reimagine how we deliver true SaaS experiences for platform engineers. Think workspaces and multi-tenancy, not namespaces in a singular cluster. Think sharding and horizontal scaling, not overly large and hard to maintain deployments. With novel approaches to well-established building blocks in Kubernetes API-Machinery, this CNCF sandbox project gives engineers a framework to host and consume any kind of API they need to support their platforms.

In this hands-on workshop, participants will learn how to extend Kubernetes with KCP, build APIs, and design controllers to tackle multi-tenancy challenges. By exploring real-world scenarios like DBaaS across clusters, attendees will gain practical skills to create scalable, multi-tenant platforms for their Kubernetes environments.
While presenting this topic in the previous couple KubeCons we got full-room attendance. However, we discovered that a 35-minute presentation to present quite complicated kcp as a framework is a challenge. One of the feedbacks we received from participants is that a workshop, covering these things in detail would be very much desired. This is a follow-up from previous sessions to deliver on the promise.

## Session outline
1. Introduction to SaaS-in-Kubernetes topic and how kcp is key element in enabling platform engineers and developers to build such SaaS platforms
2. Familiarize attendees with writing kcp-aware code
3. describe a practical example we'll help attendees create during the session
4. Work together and implement the demo.

The example would touch on hosting and consuming SaaS-like APIs we'll create during the session: self-servicing databases to be used in a web-app platform.

## Prerequisites

All these will be covered in the individual parts of the workshop, when we need them.

- Basic knowledge of Kubernetes
- Kind cluster locally installed
- kubectl installed
- krew installed
- helm installed

## Parts

- [Part 1 - Deploy kcp into kind](./part1/README.md) 
- [Part 2 - Explore workspaces](./part2/README.md)