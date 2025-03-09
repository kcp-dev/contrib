#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

export workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop-"
export KREW_ROOT="${workshop_root}/bin/.krew"
export PATH="${workshop_root}/bin/.krew/bin:${workshop_root}/bin:${PATH}"
export KUBECONFIG="${workshop_root}/.kcp/admin.kubeconfig"

[[ -f "${workshop_root}/.checkpoint-01" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

[[ -z "$(kubectl krew index list | grep 'github.com/kcp-dev/krew-index.git')" ]] \
  && kubectl krew index add kcp-dev https://github.com/kcp-dev/krew-index.git

kubectl krew install kcp-dev/kcp
kubectl krew install kcp-dev/ws
kubectl krew install kcp-dev/create-workspace

printf "\n\t🥳 krew plugins installed successfully! Continue with the next step, creating provider APIs! 💪\n\n"
