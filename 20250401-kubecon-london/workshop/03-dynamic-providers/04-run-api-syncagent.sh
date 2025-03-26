#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/api-syncagent.sh"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-02" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

kind_cluster_name='provider'
export KUBECONFIG="${KUBECONFIGS_DIR}/${kind_cluster_name}.kubeconfig"

pgrep api-syncagent &> /dev/null \
  || ::apisyncagent "postgresql.cnpg.io" "${KUBECONFIGS_DIR}/sync-agent.kubeconfig" "default"
