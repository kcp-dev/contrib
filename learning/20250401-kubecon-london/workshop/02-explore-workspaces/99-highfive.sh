#!/usr/bin/env bash

set -o nounset
set -o pipefail

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/ensure.sh"
source "${WORKSHOP_ROOT}/lib/kubectl.sh"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-01" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

ensure::internal_checkscript_kubeconfig
export KUBECONFIG="${KUBECONFIGS_DIR}/internal-checkscript.kubeconfig"

# Verify that the krew plugins are in place.

function check_krew_plugin {
  krew_plugin="${1}"
  ensure::eval_with_msg "kubectl ${krew_plugin} --help" \
    "Krew plugin '${krew_plugin}' looks good!" \
    "Krew plugin '${krew_plugin}' is missing :(\n\tTIP: Check that it's installed and in your \$PATH!"
}

check_krew_plugin "kcp"
check_krew_plugin "ws"
check_krew_plugin "create-workspace"
check_krew_plugin "create workspace"

# Verify the cowboys provider.

ensure::ws_use ":root:providers"
ensure::ws_use ":root:providers:cowboys"
ensure::apiexport_exists "cowboys"

# Verify the consumers.

ensure::ws_use ":root:consumers"

ensure::ws_use ":root:consumers:wild-west"
ensure::apibinding_exists "cowboys-consumer"

ensure::ws_use ":root:consumers:wild-north"
ensure::apibinding_exists "cowboys-consumer"

touch "${WORKSHOP_ROOT}/.checkpoint-02"
printf "\n\t🥳 High-five! Move onto the third exercise!\n\n"
