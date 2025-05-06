#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

function ensure::internal_checkscript_kubeconfig {
  [[ -f "${KUBECONFIGS_DIR}/internal-checkscript.kubeconfig" ]] \
    || cp "${WORKSHOP_ROOT}/.kcp/admin.kubeconfig" "${KUBECONFIGS_DIR}/internal-checkscript.kubeconfig"
}

function ensure::eval_with_msg {
  eval_expr="${1}"
  success_msg="${2}"
  err_msg="${3}"
  eval "${eval_expr}" > /dev/null || {
    printf "\n\t❌${err_msg}\n\n"
    exit 1
  } && { printf "\t ✅ ${success_msg}\n" ; }
}

function ensure::exists_in_kubeconfigs_dir {
  filename="${1}"
  ensure::eval_with_msg "test -f ${KUBECONFIGS_DIR}/${filename}" \
    "kubeconfig '${KUBECONFIGS_DIR}/${filename}' is in place!" \
    "kubeconfig '${KUBECONFIGS_DIR}/${filename}' is missing.\n\n\tDid you forget to copy it from .kcp/admin.kubeconfig?"
}

function ensure::process_exists {
  prog_name="${1}"
  ensure::eval_with_msg "pgrep ${prog_name}" \
    "'${prog_name}' is running!" \
    "'${prog_name}' is NOT running :("
}

function ensure::ws_use {
  ws="${1}"
  ensure::eval_with_msg "kubectl ws use ${ws}" \
    "Workspace ${ws} exists" \
    "Couldn't find workspace ${ws}. Make sure you create it!\n\tTIP: you can switch to ':root' workspace and use 'kubectl ws tree' to look around."
}

function ensure::apibinding_exists {
  apibinding_name="${1}"
  ws="$(kubectl ws . | awk -F"'" '{print $2}')"
  ensure::eval_with_msg "kubectl get apibinding ${apibinding_name}" \
    "APIBinding '${apibinding_name}' in ${ws} present!" \
    "APIBinding '${apibinding_name}' is missing in ${ws}. Make sure you create it!"
}

function ensure::apiexport_exists {
  apiexport_name="${1}"
  ws="$(kubectl ws . | awk -F"'" '{print $2}')"
  ensure::eval_with_msg "kubectl get apiexport ${apiexport_name}" \
    "APIExport '${apiexport_name}' in ${ws} present!" \
    "APIExport '${apiexport_name}' is missing in ${ws}. Make sure you create it!"
}

