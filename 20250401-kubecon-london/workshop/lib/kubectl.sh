#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

export workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop"
export KREW_ROOT="${workshop_root}/bin/.krew"
export PATH="${workshop_root}/bin/.krew/bin:${workshop_root}/bin:${PATH}"
export KUBECONFIG="${workshop_root}/.kcp/admin.kubeconfig"

function ::kubectl::ws::use {
  path="${1}"
  printf "\n✨Switching to Workspace '${path}':\n"
  printf "\$ kubectl ws use ${path}\n"
  kubectl ws use "${path}"
}

function ::kubectl::ws::create_enter {
  path="${1}"
  type="${2}"
  printf "\n\n✨Creating a Workspace '${path}' and switching to it:\n"
  printf "\$ kubectl ws create ${path} --enter\n"
  kubectl ws create --ignore-existing "${path}" --type "${type}" --enter
}

function ::kubectl::kcp::bind_apiexport {
  ws="${1}"
  apiexport="${2}"
  bindname="${3}"
  printf "\n\n✨Creating an API binding '${bindname}' that binds\n"
  printf "  Workspace '${ws}' to APIExport '${apiexport}':\n"
  printf "\$ kubectl kcp bind apiexport ${ws}:${apiexport} --name ${bindname}\n"
  kubectl get apibinding "${bindname}" &> /dev/null ||
    kubectl kcp bind apiexport "${ws}:${apiexport}" --name "${bindname}"
}

function ::kubectl::kcp::bind_with_permission_claims {
  ws="${1}"
  apiexport="${2}"
  bindname="${3}"
  accept_permission_claim="${4}"
  reject_permission_claim="${5}"
  printf "\n\n✨Creating an API binding '${bindname}' that binds\n"
  printf "  Workspace '${ws}' to APIExport '${apiexport}',\n"
  printf "  such that permission claims '${accept_permission_claim}' are accepted, and '${reject_permission_claim}' claims are rejected:\n"
  printf "\$ kubectl kcp bind apiexport ${ws}:${apiexport} --name ${bindname} --accept-permission-claim '${accept_permission_claim}' --reject-permission-claim '${reject_permission_claim}'\n"
  kubectl get apibinding "${bindname}" &> /dev/null ||
    kubectl kcp bind apiexport "${ws}:${apiexport}" --name "${bindname}" --accept-permission-claim "${accept_permission_claim}"
}

function ::kubectl::create_from_file {
  filepath="${1}"
  printf "\n\n✨Creating a resource from file '${filepath}':\n"
  printf "\$ kubectl create -f ${filepath}\n"
  kubectl get -f "${filepath}" &> /dev/null ||
    kubectl create -f "${filepath}"
}

function ::kubectl::apply_from_file {
  filepath="${1}"
  printf "\n\n✨Apply a resource from file '${filepath}':\n"
  printf "\$ kubectl apply -f ${filepath}\n"
  kubectl apply --server-side -f "${filepath}"
}

function ::kubectl::wait {
  res="${1}"
  cond="${2}"
  timeout="${3}"
  printf "\n\n✨Wait ${timeout} for '${res}' to have '${cond}':\n"
  printf "\$ kubectl wait ${res} --for=${cond} --timeout=${timeout}\n"
  kubectl wait "${res}" --for="${cond}" --timeout="${timeout}"
}
