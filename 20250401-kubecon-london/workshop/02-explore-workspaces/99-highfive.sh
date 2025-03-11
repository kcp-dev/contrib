#!/usr/bin/env bash

set -o nounset
set -o pipefail

export workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop-"
export PATH="${workshop_root}/bin:${PATH}"
export KUBECONFIG="${workshop_root}/.kcp/admin.kubeconfig"

kubectl ws use : > /dev/null
kubectl get ws consumers > /dev/null
kubectl get ws providers > /dev/null

kubectl ws use :root:providers > /dev/null
kubectl get ws cowboys > /dev/null

kubectl ws use :root:consumers > /dev/null
kubectl get ws wild-north > /dev/null
kubectl get ws wild-west > /dev/null

kubectl ws use :root:consumers:wild-north > /dev/null
kubectl get apibinding cowboys-consumer > /dev/null

kubectl ws use :root:consumers:wild-west > /dev/null
kubectl get apibinding cowboys-consumer > /dev/null

printf "\n\t ✅ Cowboy APIBindings between consumer and provider workspaces exist!\n"
touch "${workshop_root}/.checkpoint-02"

printf "\n\t🥳 High-five! Move onto the second exercise!\n\n"
