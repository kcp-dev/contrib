#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

export workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop"
export PATH="${workshop_root}/bin:${PATH}"
export KUBECONFIGS_DIR="${workshop_root}/kubeconfigs"
source "${workshop_root}/lib/kubectl.sh"

function try_or_err {
  shell_script="${1}"
  description="${2}"
  eval "${shell_script}" > /dev/null || {
    printf "\n\t❌Test for '${description}' failed!\n\n"
    exit 1
  } && { printf "\t ✅ ${description}!\n" ; }
}

export KUBECONFIG="${KUBECONFIGS_DIR}/provider.kubeconfig"
try_or_err "kubectl api-resources" "provider cluster up and running"
try_or_err "kubectl api-resources | grep postgresql.cnpg.io/v1" "PostgreSQL API available in provider cluster"

export KUBECONFIG="${KUBECONFIGS_DIR}/admin.kubeconfig"
try_or_err "::kubectl::ws::use :root:consumers:pg" "Workspace :root:consumers:pg exists"
try_or_err "kubectl get apibinding postgresql.cnpg.io" "APIBinding postgresql.cnpg.io in :root:consumers:pg exists"
try_or_err "kubectl wait cluster/kcp '--for=condition=Ready=true' --timeout=0" "kcp PostgreSQL cluster exists in the consumer workspace"
try_or_err "kubectl wait database/db-one '--for=jsonpath={.status.applied}=true' --timeout=0" "db-one PostgreSQL database exists in the consumer workspace"

touch "${workshop_root}/.checkpoint-03"
printf "\n\t🥳 High-five! Move onto the fourth exercise!\n\n"
