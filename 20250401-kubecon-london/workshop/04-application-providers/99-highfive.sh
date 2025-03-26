#!/usr/bin/env bash

set -o nounset
set -o pipefail

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/ensure.sh"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-03" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

ensure::internal_checkscript_kubeconfig
export KUBECONFIG="${KUBECONFIGS_DIR}/internal-checkscript.kubeconfig"

# Verify the application workspace and the APIExport in it.

ensure::ws_use ":root:providers:application"
ensure::apiexport_exists "apis.contrib.kcp.io"

# Verify the pg consumer workspace and that it contains the APIBinding and Application objects.

ensure::ws_use ":root:consumers:pg"
ensure::apibinding_exists "apis.contrib.kcp.io"
ensure::eval_with_msg "kubectl get application application-kcp" \
  "Application 'application-kcp' in :root:consumers:pg workspace is present!" \
  "Application 'application-kcp' not found in :root:consumers:pg workspace :( Make sure you create it!"

# Verify the mcp-example-crd process is running.

ensure::process_exists "mcp-example-crd"

# Verify the deployment in provider cluster.

provider_ns="$(kubectl get application application-kcp -o json | jq '.metadata.annotations."kcp.io/cluster"' -r)"

KUBECONFIG="${KUBECONFIGS_DIR}/provider.kubeconfig"
ensure::eval_with_msg "kubectl -n ${provider_ns} get deployment application-kcp" \
  "Application's deployment 'application-kcp' in provider kind cluster is present!" \
  "Application's deployment 'application-kcp' in provider kind cluster is NOT present :(\n\tTIP: check mcp-example-crd command line and logs."
ensure::eval_with_msg "kubectl -n ${provider_ns} rollout status deployment application-kcp --timeout=0" \
  "Application's deployment 'application-kcp' in provider kind cluster is ready and running!" \
  "Application's deployment 'application-kcp' in provider kind cluster is NOT yet ready!\n\tTIP: run 'kubectl -n ${provider_ns} get deployment application-kcp' to check its status."

printf "\n\t🥳🥳🥳 High-five! You've finished all the exercises, great job!\n\n"
