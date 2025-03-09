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
source "${workshop_root}/lib/api-syncagent.sh"

[[ -f "${workshop_root}/.checkpoint-02" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

# TODO: can we extract kubeconfig only :root:providers?
cp -L "${KUBECONFIGS_DIR}/admin.kubeconfig" "${KUBECONFIGS_DIR}/sync-agent.kubeconfig"
export KUBECONFIG="${KUBECONFIGS_DIR}/sync-agent.kubeconfig"
kubectl::ws::use ":root:providers"
kubectl::ws::create_enter "database" "root:universal"
kubectl::create_from_file "${exercise_dir}/apis/export.yaml"

export KUBECONFIG="${KUBECONFIGS_DIR}/provider.kubeconfig"
kubectl::create_from_file "https://raw.githubusercontent.com/kcp-dev/api-syncagent/refs/heads/main/deploy/crd/kcp.io/syncagent.kcp.io_publishedresources.yaml"
kubectl::create_from_file "${exercise_dir}/apis/resources-cluster.yaml"
kubectl::create_from_file "${exercise_dir}/apis/resources-database.yaml"
::apisyncagent "postgresql.cnpg.io" "${KUBECONFIGS_DIR}/sync-agent.kubeconfig" "default"

printf "\n\t🥳 PostgreSQL is now running in kind cluster 'provider'! Continue with the next step: ! 💪\n\n" "${kind_cluster_name}"
