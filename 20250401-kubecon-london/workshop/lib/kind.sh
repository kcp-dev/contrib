#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

export workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop"
export KREW_ROOT="${workshop_root}/bin/.krew"
export PATH="${workshop_root}/bin/.krew/bin:${workshop_root}/bin:${PATH}"
export KUBECONFIG="${workshop_root}/.kcp/admin.kubeconfig"

kind_service_name='workshop-kcp-kind.scope'

function ::kind::create::cluster {
  name="${1}"
  kubeconfig_path="${2}"
  printf "\n✨Creating a kind cluster '${name}':\n"
  printf "\$ kind create cluster ${name}\n"

  create_cmd="kind create cluster --name ${name} --kubeconfig ${kubeconfig_path}"

  if [ "$(uname -s)" = "Linux" ] && [ -n "${DBUS_SESSION_BUS_ADDRESS-}" ]; then
    # Assuming we're on a systemd system.
    # In certain environments (e.g. Fedora with podman), there may be
    # issues with running kind in rootless mode. Containing it in a
    # separate service with cgroups delegated to the parent process
    # works around that issue.
    # See https://kind.sigs.k8s.io/docs/user/rootless/
    # and https://lists.fedoraproject.org/archives/list/devel@lists.fedoraproject.org/thread/ZMKLS7SHMRJLJ57NZCYPBAQ3UOYULV65/
    systemd-run --user --scope \
      --unit="${kind_service_name}" \
      --property=Delegate=yes \
      ${create_cmd}
  else
    ${create_cmd}
  fi
}

function ::kind::delete::cluster {
  name="${1}"
  printf "\n✨Deleting kind cluster '${name}':\n"
  printf "\$ kind delete cluster --name ${name}\n"

  kind delete cluster --name "${name}" || true

  if [ "$(uname -s)" = "Linux" ] && [ -n "${DBUS_SESSION_BUS_ADDRESS-}" ]; then
    # Clean the scope created in ::kind::create::cluster.
    systemctl --user stop "${kind_service_name}"
    systemctl --user reset-failed "${kind_service_name}"
  fi
}
