#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

export workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop"
export KREW_ROOT="${workshop_root}/bin/.krew"
export PATH="${workshop_root}/bin/.krew/bin:${workshop_root}/bin:${PATH}"
export KUBECONFIGS_DIR="${workshop_root}/kubeconfigs"
export exercise_dir="$(dirname "${BASH_SOURCE[0]}")"
source "${workshop_root}/lib/kubectl.sh"

[[ -f "${workshop_root}/.checkpoint-03" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

export KUBECONFIG="${KUBECONFIGS_DIR}/mcp-controller.kubeconfig"
::kubectl::ws::use ":root:providers:application"
mcp-example-crd --server=$(kubectl get apiexport apis.contrib.kcp.io -o jsonpath="{.status.virtualWorkspaces[0].url}") \
  --provider-kubeconfig ${KUBECONFIGS_DIR}/provider.kubeconfig
