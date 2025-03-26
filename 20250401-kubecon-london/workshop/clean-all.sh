#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/kind.sh"

set +o errexit

pkill api-syncagent && echo "🥷 stopped api-syncagent"
pkill mcp-example-crd && echo "🥷 stopped mcp-example-crd"
pkill kcp && echo "🥷 stopped kcp"

::kind::delete::cluster "provider"

rm -rf "${KUBECONFIGS_DIR}"
rm ${WORKSHOP_ROOT}/.checkpoint-*
rm -rf ${WORKSHOP_ROOT}/.kcp
