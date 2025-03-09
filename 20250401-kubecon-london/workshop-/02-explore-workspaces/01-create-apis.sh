#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

export workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop-"
export KREW_ROOT="${workshop_root}/bin/.krew"
export PATH="${workshop_root}/bin/.krew/bin:${workshop_root}/bin:${PATH}"
export KUBECONFIG="${workshop_root}/.kcp/admin.kubeconfig"
export exercise_dir="$(dirname "${BASH_SOURCE[0]}")"
source "${workshop_root}/lib/kubectl.sh"

[[ -f "${workshop_root}/.checkpoint-01" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

kubectl::ws::use ":"

kubectl::ws::create_enter "providers" "root:organization"
kubectl::ws::create_enter "cowboys" "root:universal"

kubectl::create_from_file "${exercise_dir}/apis/apiresourceschema.yaml"
kubectl::create_from_file "${exercise_dir}/apis/apiexport.yaml"

printf "\n\t🥳 Provider APIs created successfully! Continue with the next step, creating consumers! 💪\n\n"
