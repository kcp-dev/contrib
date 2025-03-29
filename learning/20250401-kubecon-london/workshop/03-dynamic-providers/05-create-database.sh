#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/kubectl.sh"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-02" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

export KUBECONFIG="${KUBECONFIGS_DIR}/admin.kubeconfig"

::kubectl::ws::use ":root:consumers:pg"

::kubectl::create_from_file "${EXERCISE_DIR}/apis/consumer-1-cluster.yaml"
::kubectl::wait "cluster/kcp" "condition=Ready=true" "5m"

::kubectl::create_from_file "${EXERCISE_DIR}/apis/consumer-1-database.yaml"
::kubectl::wait "database/db-one" "jsonpath={.status.applied}=true" "5m"

"${EXERCISE_DIR}/99-highfive.sh"
