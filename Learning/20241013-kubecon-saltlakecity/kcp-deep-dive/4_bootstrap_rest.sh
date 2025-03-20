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

kubectl ws create operators
kubectl ws use operators

kubectl ws create mounts
kubectl ws use mounts

kubectl create -f config/mounts/resources/apibinding-targets.yaml

kind create cluster --name kind
kind get kubeconfig --name kind > kind.kubeconfig

kubectl ws use root:operators:mounts
kubectl create secret generic kind-kubeconfig --from-file=kubeconfig=kind.kubeconfig

sleep 5

# create target cluster:
kubectl create -f config/mounts/resources/example-target-cluster.yaml

# create vcluster target:
kubectl create -f config/mounts/resources/example-target-vcluster.yaml

