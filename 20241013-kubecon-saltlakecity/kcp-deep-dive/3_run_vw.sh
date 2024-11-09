#!/usr/bin/env bash

# Copyright 2024 The KCP Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/bin/bash

# Step 1: Set a fixed temporary directory
temp_dir="/tmp/kcp"

cd "$temp_dir/contrib/mounts-vw"
export KUBECONFIG=$PWD/../../.kcp/admin.kubeconfig

kubectl ws use :root
# create provider workspaces
kubectl ws create providers
kubectl ws use providers

kubectl ws create mounts
kubectl ws use mounts

# create exports
kubectl create -f config/mounts/resources/apiresourceschema-targetkubeclusters.targets.contrib.kcp.io.yaml
kubectl create -f config/mounts/resources/apiresourceschema-kubeclusters.mounts.contrib.kcp.io.yaml
kubectl create -f config/mounts/resources/apiresourceschema-targetvclusters.targets.contrib.kcp.io.yaml
kubectl create -f config/mounts/resources/apiresourceschema-vclusters.mounts.contrib.kcp.io.yaml
kubectl create -f config/mounts/resources/apiexport-mounts.contrib.kcp.io.yaml
kubectl create -f config/mounts/resources/apiexport-targets.contrib.kcp.io.yaml

echo "sleep 10, waiting for the resources to be created"
sleep 10

kubectl ws use :root

 go run ./cmd/virtual-workspaces/ start \
 --kubeconfig=../../.kcp/admin.kubeconfig  \
 --tls-cert-file=../../.kcp/apiserver.crt \
 --tls-private-key-file=../../.kcp/apiserver.key \
 --authentication-kubeconfig=../../.kcp/admin.kubeconfig \
 --virtual-workspaces-proxy-hostname=https://localhost:6444 \
 -v=8
