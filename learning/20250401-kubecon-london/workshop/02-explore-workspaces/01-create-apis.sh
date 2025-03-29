#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/kubectl.sh"
export KUBECONFIG="${KUBECONFIGS_DIR}/admin.kubeconfig"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-01" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

::kubectl::ws::use ":"

::kubectl::ws::create_enter "providers" "root:organization"
::kubectl::ws::create_enter "cowboys" "root:universal"

::kubectl::create_from_file "${EXERCISE_DIR}/apis/apiresourceschema.yaml"
::kubectl::create_from_file "${EXERCISE_DIR}/apis/apiexport.yaml"

printf "\n\t🥳 Provider APIs created successfully! Continue with the next step, creating consumers! 💪\n\n"
