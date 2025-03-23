#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/kubectl.sh"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-02" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

export KUBECONFIG="${KUBECONFIGS_DIR}/admin.kubeconfig"
::kubectl::ws::use ":root:consumers"
::kubectl::ws::create_enter "pg" "root:universal"
::kubectl::kcp::bind_with_permission_claims "root:providers:database" "postgresql.cnpg.io" "postgresql.cnpg.io" "secrets.core,namespaces.core" ""
