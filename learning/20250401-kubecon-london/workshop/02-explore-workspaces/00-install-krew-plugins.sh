#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-01" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

[[ -z "$(kubectl krew index list | grep 'github.com/kcp-dev/krew-index.git')" ]] \
  && kubectl krew index add kcp-dev https://github.com/kcp-dev/krew-index.git

kubectl krew install kcp-dev/kcp
kubectl krew install kcp-dev/ws
kubectl krew install kcp-dev/create-workspace

# IMPORTANT HACK: https://github.com/kubernetes-sigs/krew/issues/865
cp $(which kubectl-create_workspace) $KREW_ROOT/bin/kubectl-create-workspace

printf "\n\t🥳 krew plugins installed successfully! Continue with the next step, creating provider APIs! 💪\n\n"
