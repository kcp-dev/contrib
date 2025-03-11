#!/usr/bin/env bash

set -o nounset
set -o pipefail

export workshop_root="$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop-"
export GOOS="$( uname | tr '[:upper:]' '[:lower:]' | grep -E 'linux|darwin' )"
export GOARCH="$( uname -m | sed 's/x86_64/amd64/ ; s/aarch64/arm64/' | grep -E 'amd64|arm64' )"

set -o errexit

[[ -n "${GOOS}" ]] || { echo "Unsupported OS: $(uname)" 1>&2 ; exit 1 ; }
[[ -n "${GOARCH}" ]] || { echo "Unsupported platform: $(uname -m)" 1>&2 ; exit 1 ; }

if [[ ! -f "${workshop_root}/bin/.checkpoint-kcp" ]]; then
  echo "🚀 Downloading kcp"
  curl -L "https://github.com/kcp-dev/kcp/releases/download/v0.26.1/kcp_0.26.1_${GOOS}_${GOARCH}.tar.gz" \
    | tar -C "${workshop_root}" -xzf - bin/kcp
  touch "${workshop_root}/bin/.checkpoint-kcp"
fi

if [[ ! -f "${workshop_root}/bin/.checkpoint-api-syncagent" ]]; then
    echo "🚀 Downloading api-syncagent"
    curl -L "https://github.com/kcp-dev/api-syncagent/releases/download/v0.2.0-alpha.0/api-syncagent_0.2.0-alpha.0_${GOOS}_${GOARCH}.tar.gz" \
      | tar -C "${workshop_root}/bin" -xzf - api-syncagent
    touch "${workshop_root}/bin/.checkpoint-api-syncagent"
fi

if [[ ! -f "${workshop_root}/bin/.checkpoint-kind" ]]; then
  echo "🚀 Downloading kind"
  curl -Lo "${workshop_root}/bin/kind" "https://github.com/kubernetes-sigs/kind/releases/download/v0.27.0/kind-${GOOS}-${GOARCH}"
  chmod +x "${workshop_root}/bin/kind"
  touch "${workshop_root}/bin/.checkpoint-kind"
fi

if [[ ! -f "${workshop_root}/bin/.checkpoint-kubectl" ]]; then
  echo "🚀 Downloading kubectl"
  curl -Lo "${workshop_root}/bin/kubectl" "https://dl.k8s.io/v1.31.6/bin/${GOOS}/${GOARCH}/kubectl"
  chmod +x "${workshop_root}/bin/kubectl"
  touch "${workshop_root}/bin/.checkpoint-kubectl"
fi

if [[ ! -f "${workshop_root}/bin/.checkpoint-kubectl-krew" ]]; then
  echo "🚀 Downloading kubectl-krew"
  curl -L "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-${GOOS}_${GOARCH}.tar.gz" \
    | tar -xzf - --strip-components=1 -C "${workshop_root}/bin" "./krew-${GOOS}_${GOARCH}"
  mv "${workshop_root}/bin/krew-${GOOS}_${GOARCH}" "${workshop_root}/bin/kubectl-krew"
  touch "${workshop_root}/bin/.checkpoint-kubectl-krew"
fi

"${workshop_root}/00-prerequisites/99-highfive.sh"
