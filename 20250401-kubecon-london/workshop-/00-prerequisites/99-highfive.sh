#!/usr/bin/env bash

set -o nounset
set -o pipefail

workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop-"
export PATH="${workshop_root}/bin:${PATH}"

function check_exec {
  prog="${1}"
  args="${@:2}"
  "${1}" ${args} > /dev/null || {
    printf "\n\t❌It seems '${prog}' is not working!\n\n"
    exit 1
  } && { printf "\t ✅ '${prog}' looks good!\n" ; }
}

check_exec "kcp" "--version"
check_exec "kind" "version"
check_exec "kubectl" "version --client"
check_exec "kubectl-krew" "version"

touch "${workshop_root}/.checkpoint-00"

printf "\n\t🥳 High-five! Move onto the first exercise!\n\n"
