#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/kubectl.sh"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-02" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

export KUBECONFIG="${KUBECONFIGS_DIR}/sync-agent.kubeconfig"
kind_cluster_name='provider'

::kubectl::ws::use ":root:providers"
::kubectl::ws::create_enter "database" "root:universal"
::kubectl::create_from_file "${EXERCISE_DIR}/apis/export.yaml"

printf "\n\t🥳 The pgsql provider is now created! Continue with the next step: creating a consumer! 💪\n\n"
