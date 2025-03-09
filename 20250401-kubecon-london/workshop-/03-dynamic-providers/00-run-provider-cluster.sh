#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

export workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop-"
export KREW_ROOT="${workshop_root}/bin/.krew"
export PATH="${workshop_root}/bin/.krew/bin:${workshop_root}/bin:${PATH}"
export KUBECONFIGS_DIR="${workshop_root}/kubeconfigs"
export exercise_dir="$(dirname "${BASH_SOURCE[0]}")"
source "${workshop_root}/lib/kubectl.sh"

[[ -f "${workshop_root}/.checkpoint-02" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

kind_cluster_name='provider'
systemd_scope_name='workshop-kcp-kind.scope'

# Determine OS platform
OS=$(uname -s)

if [ "$OS" = "Linux" ]; then
    # Assume Linux distros with systemd (like Fedora)
    if ! systemctl is-active --user "${systemd_scope_name}" -q; then
        echo "🚀 Starting up a kind cluster '${kind_cluster_name}'"
        systemctl --user reset-failed "${systemd_scope_name}"
        systemd-run --scope --unit="${systemd_scope_name}" --user -p "Delegate=yes" \
            kind create cluster --name provider  --kubeconfig "${KUBECONFIGS_DIR}/provider.kubeconfig"
    fi
elif [ "$OS" = "Darwin" ]; then
    # macOS, which does not use systemd
    # Check if a kind cluster is running
    if ! pgrep -f "kind create cluster --name provider" > /dev/null; then
        echo "🚀 Starting up a kind cluster '${kind_cluster_name}'"
        # Start the kind cluster
        kind create cluster --name provider --kubeconfig "${KUBECONFIGS_DIR}/provider.kubeconfig" &
    fi
else
    echo "Unsupported operating system."
fi

KUBECONFIG="${KUBECONFIGS_DIR}/provider.kubeconfig" kubectl version > /dev/null

printf "\n\t🥳 kind cluster '%s' is running! Continue with the next step: ! 💪\n\n" "${kind_cluster_name}"
