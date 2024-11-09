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
temp_dir="/tmp/generic-controlplane"

cp ./crds $temp_dir -r

cd "$temp_dir"

export KUBECONFIG="$temp_dir/.gcp/admin.kubeconfig"


# Wait for user to press any key
echo "KUBECONFIG ready. Press any key to continue..."
read -n 1 -s

echo "kubectl api-resources"
read -n 1 -s
kubectl api-resources

read -n 1 -s

echo "kubectl create -f crds/*"
read -n 1 -s
kubectl create -f crds/*

read -n 1 -s

echo "kubectl get crds"
read -n 1 -s
kubectl get crds

read -n 1 -s

echo "kubectl get namespaces"
read -n 1 -s
kubectl get namespaces

echo "Stop the 'go run' process and go back to slides!"
exit 0
