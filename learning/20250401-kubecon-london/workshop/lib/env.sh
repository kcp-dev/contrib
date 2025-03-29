#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

parent_path="${1}"

export WORKSHOP_ROOT="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop"
export KREW_ROOT="${WORKSHOP_ROOT}/bin/.krew"
export PATH="${WORKSHOP_ROOT}/bin/.krew/bin:${WORKSHOP_ROOT}/bin:${PATH}"
export KUBECONFIGS_DIR="${WORKSHOP_ROOT}/kubeconfigs"
export EXERCISE_DIR="${parent_path}"
