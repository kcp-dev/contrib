#!/usr/bin/env bash

set -o nounset
set -o pipefail

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/ensure.sh"

function check_in_path {
  prog="${1}"
  args="${@:2}"
  ensure::eval_with_msg "${prog} ${args}" \
    "'${prog}' looks good!" \
    "It seems '${prog}' is not available :(\n\tTIP: Make sure it's installed and available in your \$PATH or ${WORKSHOP_ROOT}/bin."
}

check_in_path "kcp" "--version"
check_in_path "kind" "version"
check_in_path "kubectl" "version --client"
check_in_path "kubectl-krew" "version"
check_in_path "mcp-example-crd" "-h" 2> /dev/null

touch "${WORKSHOP_ROOT}/.checkpoint-00"
printf "\n\t🥳 High-five! Move onto the first exercise!\n\n"
