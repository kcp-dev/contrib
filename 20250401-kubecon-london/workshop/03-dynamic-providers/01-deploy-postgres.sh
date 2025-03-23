#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/kubectl.sh"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-02" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

export KUBECONFIG="${KUBECONFIGS_DIR}/provider.kubeconfig"
kind_cluster_name='provider'

::kubectl::apply_from_file 'https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.25/releases/cnpg-1.25.1.yaml'
::kubectl::apply_from_file 'https://raw.githubusercontent.com/kcp-dev/api-syncagent/refs/heads/main/deploy/crd/kcp.io/syncagent.kcp.io_publishedresources.yaml'
::kubectl::apply_from_file "${EXERCISE_DIR}/apis/resources-cluster.yaml"
::kubectl::apply_from_file "${EXERCISE_DIR}/apis/resources-database.yaml"

printf "\n\t🥳 PostgreSQL is now running in kind cluster 'provider'! Continue with the next step: ! 💪\n\n" "${kind_cluster_name}"
