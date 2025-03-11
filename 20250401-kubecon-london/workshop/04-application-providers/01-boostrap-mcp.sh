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
export PROVIDER_KUBECONFIG="${KUBECONFIGS_DIR}/provider.kubeconfig"

::kubectl::ws::use ":root:providers"
::kubectl::ws::create_enter "application" "root:universal"
::kubectl::create_from_file "${exercise_dir}/apis/apiresourceschema.yaml"
::kubectl::create_from_file "${exercise_dir}/apis/export.yaml"

printf "\n\t🥳 You are good to go! \n\t"
