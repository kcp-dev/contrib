#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/kubectl.sh"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-03" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

export KUBECONFIG="${KUBECONFIGS_DIR}/admin.kubeconfig"

::kubectl::ws::use ":root:consumers:pg"
::kubectl::kcp::bind_with_permission_claims "root:providers:application" "apis.contrib.kcp.io" "apis.contrib.kcp.io" "secrets.core" ""
::kubectl::create_from_file "${EXERCISE_DIR}/apis/application.yaml"

printf "\n\t🥳 The application consumer is now created! Continue with the next step: running the mcp-example-crd Application controller! 💪\n\n"
