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

export KUBECONFIG="${KUBECONFIGS_DIR}/admin.kubeconfig"

::kubectl::ws::use ":root:consumers:pg"
# TODO: add flag to accept secrets
# ::kubectl::kcp::bind_apiexport "root:providers:application" "apis.contrib.kcp.io" "apis.contrib.kcp.io"
::kubectl::kcp::bind_with_permission_claims "root:providers:application" "apis.contrib.kcp.io" "apis.contrib.kcp.io" "secrets.core" ""
::kubectl::create_from_file "${exercise_dir}/apis/application.yaml"

# TODO(Add how to port forward from the application)

