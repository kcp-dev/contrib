#!/usr/bin/env bash

set -o nounset
set -o pipefail

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
export KUBECONFIG="${KUBECONFIGS_DIR}/admin.kubeconfig"

kubectl version &> /dev/null || { printf "\n\t❌It seems kcp is down :( !\n\n" ; exit 1 ; }
printf "\t ✅ kcp is up and running!\n"
touch "${WORKSHOP_ROOT}/.checkpoint-01"

printf "\n\t🥳 High-five! Move onto the second exercise!\n\n"
