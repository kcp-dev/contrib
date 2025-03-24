#!/usr/bin/env bash

set -o nounset
set -o pipefail

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/ensure.sh"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-00" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

ensure::process_exists "kcp"
ensure::exists_in_kubeconfigs_dir "admin.kubeconfig"
ensure::internal_checkscript_kubeconfig
export KUBECONFIG="${KUBECONFIGS_DIR}/internal-checkscript.kubeconfig"
ensure::eval_with_msg "kubectl version" "kcp is reachable!" "It seems kcp is down :("

touch "${WORKSHOP_ROOT}/.checkpoint-01"
printf "\n\t🥳 High-five! Move onto the second exercise!\n\n"
