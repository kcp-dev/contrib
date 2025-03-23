#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-00" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

function try_with_timeout {
  attempts=15
  while [[ "${attempts}" -gt 0 ]]; do
    kubectl version &> /dev/null && return
    sleep 5
    attempts=$((attempts-1))
  done
  printf "\n\t❌kcp takes too long to start, maybe something is wrong?\n"
  exit 1
}

pgrep kcp &> /dev/null && { "${EXERCISE_DIR}/99-highfive.sh" ; exit $? ; }

cd "${WORKSHOP_ROOT}"

kcp start & kcp_pid=$!
trap 'kill -TERM ${kcp_pid}' TERM INT EXIT
export KUBECONFIG="${WORKSHOP_ROOT}/.kcp/admin.kubeconfig"
try_with_timeout

mkdir -p "${KUBECONFIGS_DIR}"

cp "${WORKSHOP_ROOT}/.kcp/admin.kubeconfig" "${KUBECONFIGS_DIR}/admin.kubeconfig"
cp "${WORKSHOP_ROOT}/.kcp/admin.kubeconfig" "${KUBECONFIGS_DIR}/sync-agent.kubeconfig"
cp "${WORKSHOP_ROOT}/.kcp/admin.kubeconfig" "${KUBECONFIGS_DIR}/mcp-controller.kubeconfig"

"${EXERCISE_DIR}/99-highfive.sh"
wait "${kcp_pid}"
