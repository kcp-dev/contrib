#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/kubectl.sh"
export KUBECONFIG="${KUBECONFIGS_DIR}/admin.kubeconfig"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-01" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

::kubectl::ws::use ":"

::kubectl::ws::create_enter "consumers" "root:organization"
::kubectl::ws::create_enter "wild-west" "root:universal"
::kubectl::kcp::bind_with_permission_claims "root:providers:cowboys" "cowboys" "cowboys-consumer" "configmaps.core" ""

::kubectl::create_from_file "${EXERCISE_DIR}/apis/consumer-wild-west.yaml"

::kubectl::ws::use :root:consumers
::kubectl::ws::create_enter "wild-north" "root:universal"
::kubectl::kcp::bind_with_permission_claims "root:providers:cowboys" "cowboys" "cowboys-consumer" "configmaps.core" ""
::kubectl::create_from_file "${EXERCISE_DIR}/apis/consumer-wild-north.yaml"

"${EXERCISE_DIR}/99-highfive.sh"
