#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

export workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop-"
export KREW_ROOT="${workshop_root}/bin/.krew"
export PATH="${workshop_root}/bin/.krew/bin:${workshop_root}/bin:${PATH}"
export KUBECONFIG="${workshop_root}/.kcp/admin.kubeconfig"

function kind::cluster::create {
  name="${1}"
  printf "\n✨Creating a kind cluster '${name}':\n"
  printf "\$ kind cluster create ${name}\n"
  kind cluster create "${name}"
}
