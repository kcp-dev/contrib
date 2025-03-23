#!/usr/bin/env bash

set -o nounset
set -o pipefail

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/kubectl.sh"
export KUBECONFIG="${KUBECONFIGS_DIR}/admin.kubeconfig"

kubectl ws use ":" > /dev/null
kubectl get ws consumers > /dev/null
kubectl get ws providers > /dev/null

kubectl ws use ":root:providers" > /dev/null
kubectl get ws cowboys > /dev/null

kubectl ws use ":root:consumers" > /dev/null
kubectl get ws wild-north > /dev/null
kubectl get ws wild-west > /dev/null

kubectl ws use ":root:consumers:wild-north" > /dev/null
kubectl get apibinding cowboys-consumer > /dev/null

kubectl ws use ":root:consumers:wild-west" > /dev/null
kubectl get apibinding cowboys-consumer > /dev/null

printf "\n\t ✅ Cowboy APIBindings between consumer and provider workspaces exist!\n"
touch "${WORKSHOP_ROOT}/.checkpoint-02"

printf "\n\t🥳 High-five! Move onto the second exercise!\n\n"
