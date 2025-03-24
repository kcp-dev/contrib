#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/kubectl.sh"
source "${WORKSHOP_ROOT}/lib/kind.sh"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-02" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

kind_cluster_name='provider'
kind_kubeconfig="${KUBECONFIGS_DIR}/${kind_cluster_name}.kubeconfig"
::kind::create::cluster "${kind_cluster_name}" "${kind_kubeconfig}"

KUBECONFIG="${kind_kubeconfig}" kubectl version > /dev/null

printf "\n\t🥳 kind cluster '%s' is running! Continue with the next step: deploying PostgresSQL! 💪\n\n" "${kind_cluster_name}"
