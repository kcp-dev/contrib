#!/bin/bash

cp ../1-deploy-kcp-easy-way/.kcp/admin.kubeconfig admin.kubeconfig
cp ../1-deploy-kcp-easy-way/.kcp/admin.kubeconfig sync-agent.kubeconfig

kind create cluster --name provider 
kind get kubeconfig --name provider > provider.kubeconfig
