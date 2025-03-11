#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

export workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop-"
export KREW_ROOT="${workshop_root}/bin/.krew"
export PATH="${workshop_root}/bin/.krew/bin:${workshop_root}/bin:${PATH}"
export KUBECONFIGS_DIR="${workshop_root}/kubeconfigs"
export exercise_dir="$(dirname "${BASH_SOURCE[0]}")"
source "${workshop_root}/lib/kubectl.sh"
source "${workshop_root}/lib/kind.sh"

[[ -f "${workshop_root}/.checkpoint-02" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

kind_cluster_name='provider'
kind_kubeconfig="${KUBECONFIGS_DIR}/${kind_cluster_name}.kubeconfig"
::kind::create::cluster "${kind_cluster_name}" "${kind_kubeconfig}"

KUBECONFIG="${kind_kubeconfig}" kubectl version > /dev/null

printf "\n\t🥳 kind cluster '%s' is running! Continue with the next step: ! 💪\n\n" "${kind_cluster_name}"
