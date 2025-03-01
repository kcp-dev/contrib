#!/bin/bash

export KCP_KUBECONFIG=../1-deploy-kcp-easy-way/.kcp/admin.kubeconfig
kind get kubeconfig --name provider > provider.kubeconfig

export KUBECONFIG=provider.kubeconfig
kubectl create -f https://raw.githubusercontent.com/kcp-dev/api-syncagent/refs/heads/main/deploy/crd/kcp.io/syncagent.kcp.io_publishedresources.yaml
kubectl create -f apis/resources-postgres.yaml

