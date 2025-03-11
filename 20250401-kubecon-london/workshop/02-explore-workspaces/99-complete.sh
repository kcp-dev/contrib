#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop-"
export exercise_dir="$(dirname "${BASH_SOURCE[0]}")"

"${workshop_root}01-deploy-kcp/99-complete.sh"
"${exercise_dir}/00-install-krew-plugins.sh"
"${exercise_dir}/01-create-apis.sh"
"${exercise_dir}/02-create-consumers.sh"
