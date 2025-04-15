#!/usr/bin/env bash

set -o nounset
set -o pipefail

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
export GOOS="$( uname | tr '[:upper:]' '[:lower:]' | grep -E 'linux|darwin' )"
export GOARCH="$( uname -m | sed 's/x86_64/amd64/ ; s/aarch64/arm64/' | grep -E 'amd64|arm64' )"

set -o errexit

[[ -n "${GOOS}" ]] || { echo "Unsupported OS: $(uname)" 1>&2 ; exit 1 ; }
[[ -n "${GOARCH}" ]] || { echo "Unsupported platform: $(uname -m)" 1>&2 ; exit 1 ; }

if [[ ! -f "${WORKSHOP_ROOT}/bin/.checkpoint-kcp" ]]; then
  echo "🚀 Downloading kcp"
  curl -L "https://github.com/kcp-dev/kcp/releases/download/v0.26.1/kcp_0.26.1_${GOOS}_${GOARCH}.tar.gz" \
    | tar -C "${WORKSHOP_ROOT}" -xzf - bin/kcp
  touch "${WORKSHOP_ROOT}/bin/.checkpoint-kcp"
fi

if [[ ! -f "${WORKSHOP_ROOT}/bin/.checkpoint-api-syncagent" ]]; then
    echo "🚀 Downloading api-syncagent"
    curl -L "https://github.com/kcp-dev/api-syncagent/releases/download/v0.2.0-alpha.1/api-syncagent_0.2.0-alpha.1_${GOOS}_${GOARCH}.tar.gz" \
      | tar -C "${WORKSHOP_ROOT}/bin" -xzf - api-syncagent
    touch "${WORKSHOP_ROOT}/bin/.checkpoint-api-syncagent"
fi

if [[ ! -f "${WORKSHOP_ROOT}/bin/.checkpoint-mcp-example-crd" ]]; then
    echo "🚀 Downloading KCP's mcp-example-crd"
    curl -L "https://github.com/kcp-dev/contrib/releases/download/v1-kubecon2025-london/contrib_1-kubecon2025-london_${GOOS}_${GOARCH}.tar.gz" \
      | tar -C "${WORKSHOP_ROOT}/bin" -xzf - mcp-example-crd
    touch "${WORKSHOP_ROOT}/bin/.checkpoint-mcp-example-crd"
fi

if [[ ! -f "${WORKSHOP_ROOT}/bin/.checkpoint-kind" ]]; then
  echo "🚀 Downloading kind"
  curl -Lo "${WORKSHOP_ROOT}/bin/kind" "https://github.com/kubernetes-sigs/kind/releases/download/v0.27.0/kind-${GOOS}-${GOARCH}"
  chmod +x "${WORKSHOP_ROOT}/bin/kind"
  touch "${WORKSHOP_ROOT}/bin/.checkpoint-kind"
fi

if [[ ! -f "${WORKSHOP_ROOT}/bin/.checkpoint-kubectl" ]]; then
  echo "🚀 Downloading kubectl"
  curl -Lo "${WORKSHOP_ROOT}/bin/kubectl" "https://dl.k8s.io/v1.31.7/bin/${GOOS}/${GOARCH}/kubectl"
  chmod +x "${WORKSHOP_ROOT}/bin/kubectl"
  touch "${WORKSHOP_ROOT}/bin/.checkpoint-kubectl"
fi

if [[ ! -f "${WORKSHOP_ROOT}/bin/.checkpoint-kubectl-krew" ]]; then
  echo "🚀 Downloading kubectl-krew"
  curl -L "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-${GOOS}_${GOARCH}.tar.gz" \
    | tar -xzf - --strip-components=1 -C "${WORKSHOP_ROOT}/bin" "./krew-${GOOS}_${GOARCH}"
  mv "${WORKSHOP_ROOT}/bin/krew-${GOOS}_${GOARCH}" "${WORKSHOP_ROOT}/bin/kubectl-krew"
  touch "${WORKSHOP_ROOT}/bin/.checkpoint-kubectl-krew"
fi

if [[ ! -f "${WORKSHOP_ROOT}/bin/.checkpoint-jq" ]]; then
  os="${GOOS}"
  [[ "${os}" == "darwin" ]] && os="macos"
  echo "🚀 Downloading jq"
  curl -Lo "${WORKSHOP_ROOT}/bin/jq" "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-${os}-${GOARCH}"
  chmod +x "${WORKSHOP_ROOT}/bin/jq"
  touch "${WORKSHOP_ROOT}/bin/.checkpoint-jq"
fi

"${EXERCISE_DIR}/99-highfive.sh"
