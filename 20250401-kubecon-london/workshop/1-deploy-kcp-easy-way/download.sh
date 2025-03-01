#!/bin/bash
# Define the version and base release URL
VERSION="0.26.1"
RELEASE_URL="https://github.com/kcp-dev/kcp/releases/download/v${VERSION}"

# Determine OS type (e.g., darwin, linux)
OS=$(uname | tr '[:upper:]' '[:lower:]')
if [[ "$OS" == "darwin" ]]; then
  PLATFORM="darwin"
elif [[ "$OS" == "linux" ]]; then
  PLATFORM="linux"
else
  echo "Unsupported OS: $OS"
  exit 1
fi

# Determine architecture (e.g., amd64, arm64)
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
  ARCH="amd64"
elif [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
  ARCH="arm64"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

# Construct the tarball name for the binary
TARBALL="kcp_${VERSION}_${PLATFORM}_${ARCH}.tar.gz"

# Download the binary tarball
echo "Downloading ${TARBALL}..."
curl -LO "${RELEASE_URL}/${TARBALL}"

# Extract the binary
mkdir -p ./kcp
tar xzf "${TARBALL}" -C ./kcp

