#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

export workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop"
export PATH="${workshop_root}/bin:${PATH}"
export KUBECONFIGS_DIR="${workshop_root}/kubeconfigs"
source "${workshop_root}/lib/kind.sh"

set +o errexit

pkill api-syncagent && echo "🥷 stopped api-syncagent"
pkill kcp && echo "🥷 stopped kcp"

kind_cluster_name='provider'
::kind::delete::cluster "${kind_cluster_name}"

rm -rf "${KUBECONFIGS_DIR}"
rm ${workshop_root}/.checkpoint-*
