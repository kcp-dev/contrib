#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

function ::mcpexamplecrd {
  server="${1}"
  provider="${2}"
  printf "\n✨Running mcp-example-crd, reconciling Application resource\n"
  printf "  from '${server}' in provider '${provider}'\n"
  printf "\$ mcp-example-crd --server "${apiexport_name}" --provider-kubeconfig "${provider}"\n"
  mcp-example-crd --server "${apiexport_name}" --provider-kubeconfig "${provider}"
}
