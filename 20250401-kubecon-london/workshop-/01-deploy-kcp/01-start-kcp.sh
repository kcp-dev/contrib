#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

export workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop-"
export PATH="${workshop_root}/bin:${PATH}"
export KUBECONFIG="${workshop_root}/.kcp/admin.kubeconfig"

[[ -f "${workshop_root}/.checkpoint-00" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

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

cd "${workshop_root}"

kcp start & kcp_pid=$!
trap 'kill -TERM ${kcp_pid}' TERM INT EXIT
try_with_timeout

export KUBECONFIGS_DIR="${workshop_root}/kubeconfigs"
mkdir -p "${KUBECONFIGS_DIR}"
cp "${workshop_root}/.kcp/admin.kubeconfig" "${KUBECONFIGS_DIR}/admin.kubeconfig"
# Create a kubeconfig for the sync-agent just in case we need it
cp "${workshop_root}/.kcp/admin.kubeconfig" "${KUBECONFIGS_DIR}/sync-agent.kubeconfig"

"${workshop_root}/01-deploy-kcp/99-highfive.sh"
wait "${kcp_pid}"
