#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

export workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop-"
export KREW_ROOT="${workshop_root}/bin/.krew"
export PATH="${workshop_root}/bin/.krew/bin:${workshop_root}/bin:${PATH}"
export KUBECONFIGS_DIR="${workshop_root}/kubeconfigs"
export exercise_dir="$(dirname "${BASH_SOURCE[0]}")"
source "${workshop_root}/lib/kubectl.sh"
source "${workshop_root}/lib/api-syncagent.sh"

[[ -f "${workshop_root}/.checkpoint-02" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

export KUBECONFIG="${KUBECONFIGS_DIR}/mcp-controller.kubeconfig"
export PROVIDER_KUBECONFIG="${KUBECONFIGS_DIR}/provider.kubeconfig"


::kubectl::ws::use ":root:providers:application"
::kubectl::ws::create_enter "database" "root:universal"

export KUBECONFIG="${KUBECONFIGS_DIR}/provider.kubeconfig"
./mcp --server=$(kubectl get apiexport apis.contrib.kcp.io -o jsonpath="{.status.virtualWorkspaces[0].url}") \
        --provider-kubeconfig ${KUBECONFIGS_DIR}/provider.kubeconfig 

printf "\n\t🥳 MCP is now running. Get next terminal ! 💪\n\n"



