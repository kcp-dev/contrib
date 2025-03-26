#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

function ::apisyncagent {
  apiexport_name="${1}"
  kcp_kubeconfig="${2}"
  target_namespace="${3}"
  printf "\n✨Running api-syncagent, syncing '${apiexport_name}' APIExport from cluster '${kcp_kubeconfig}'\n"
  printf "  into '${KUBECONFIG}', inside namespace '${target_namespace}:\n"
  printf "\$ api-syncagent --apiexport-ref "${apiexport_name}" --kcp-kubeconfig "${kcp_kubeconfig}" --namespace "${target_namespace}"\n"
  api-syncagent --apiexport-ref "${apiexport_name}" --kcp-kubeconfig "${kcp_kubeconfig}" --namespace "${target_namespace}"
}
