#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/kubectl.sh"
source "${WORKSHOP_ROOT}/lib/mcp-example-crd.sh"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-03" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

export KUBECONFIG="${KUBECONFIGS_DIR}/mcp-controller.kubeconfig"
::kubectl::ws::use ":root:providers:application"

pgrep mcp-example-crd &> /dev/null \
  || ::mcpexamplecrd "$(kubectl get apiexport apis.contrib.kcp.io -o jsonpath='{.status.virtualWorkspaces[0].url}')" "${KUBECONFIGS_DIR}/provider.kubeconfig"
