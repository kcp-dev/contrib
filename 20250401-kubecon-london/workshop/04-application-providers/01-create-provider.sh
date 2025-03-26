#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/kubectl.sh"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-03" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

export KUBECONFIG="${KUBECONFIGS_DIR}/mcp-controller.kubeconfig"
::kubectl::ws::use ":root:providers"
::kubectl::ws::create_enter "application" "root:universal"
::kubectl::create_from_file "${EXERCISE_DIR}/apis/apiresourceschema.yaml"
::kubectl::create_from_file "${EXERCISE_DIR}/apis/export.yaml"

printf "\n\t🥳 The application provider is now created! Continue with the next step: creating an application consumer! 💪\n\n"
