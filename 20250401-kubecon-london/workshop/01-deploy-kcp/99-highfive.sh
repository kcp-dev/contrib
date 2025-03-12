#!/usr/bin/env bash

set -o nounset
set -o pipefail

export workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop"
export PATH="${workshop_root}/bin:${PATH}"
export KUBECONFIG="${workshop_root}/.kcp/admin.kubeconfig"

kubectl version &> /dev/null || { printf "\n\t❌It seems kcp is down :( !\n\n" ; exit 1 ; }
printf "\t ✅ kcp is up and running!\n"
touch "${workshop_root}/.checkpoint-01"

printf "\n\t🥳 High-five! Move onto the second exercise!\n\n"
