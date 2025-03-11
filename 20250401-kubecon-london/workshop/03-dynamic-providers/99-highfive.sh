#!/usr/bin/env bash

set -o nounset
set -o pipefail

export workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop-"
export PATH="${workshop_root}/bin:${PATH}"
export KUBECONFIG="${workshop_root}/.kcp/admin.kubeconfig"


