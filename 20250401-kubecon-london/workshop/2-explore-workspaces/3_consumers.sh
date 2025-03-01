#!/bin/bash

export KUBECONFIG=../1-deploy-kcp-easy-way/.kcp/admin.kubeconfig

kubectl ws use :
kubectl ws create consumers --enter

kubectl ws create wild-west --enter
kubectl kcp bind apiexport root:providers:cowboys:cowboys cowboys-consumer 
kubectl create -f apis/consumer-wild-west.yaml

kubectl ws use :root:consumers
kubectl ws create wild-north --enter
kubectl kcp bind apiexport root:providers:cowboys:cowboys cowboys-consumer 
kubectl create -f apis/consumer-wild-north.yaml