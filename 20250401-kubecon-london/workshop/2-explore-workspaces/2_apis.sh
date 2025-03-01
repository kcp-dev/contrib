#!/bin/bash

export KUBECONFIG=../1-deploy-kcp-easy-way/.kcp/admin.kubeconfig

kubectl ws use :
kubectl ws create providers --enter
kubectl ws create cowboys --enter

kubectl create -f apis/apiresourceschema.yaml
kubectl create -f apis/apiexport.yaml

