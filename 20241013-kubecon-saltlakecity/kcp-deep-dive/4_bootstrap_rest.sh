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


# Initialize the variable as empty
kubeSecretString=""

# Loop until kubeSecretString is not empty
while [[ -z "$kubeSecretString" ]]; do
  # Run the kubectl command and assign the result to the variable
  kubeSecretString=$(kubectl get TargetKubeCluster proxy-cluster -o jsonpath='{.status.secretString}')

  # Wait for a short period before checking again to avoid excessive requests
  sleep 2
done

# Print the result or proceed with your next steps
echo "Secret String for KubeCluster is ready: $kubeSecretString"

# Initialize the variable as empty
vclusterSecretString=""

# Loop until kubeSecretString is not empty
while [[ -z "$vclusterSecretString" ]]; do
  # Run the kubectl command and assign the result to the variable
  vclusterSecretString=$(kubectl get TargetVCluster proxy-cluster -o jsonpath='{.status.secretString}')

  # Wait for a short period before checking again to avoid excessive requests
  sleep 2
done

# Print the result or proceed with your next steps
echo "Secret String for VCluster is ready: $vclusterSecretString"

# Create a consumer workspace for mounts:

echo "Create consumer workspace for mounts"
kubectl ws use :root
kubectl ws create consumer
kubectl ws use consumer
kubectl ws create kind-cluster

kubectl create -f config/mounts/resources/apibinding-mounts.yaml

cat /tmp/kcp/contrib/mounts-vw/config/mounts/resources/example-mount-cluster.yaml | yq '.spec.secretString= env(kubeSecretString)' - > /tmp/kcp/contrib/mounts-vw/config/mounts/resources/example-mount-cluster.yaml_new

cat /tmp/kcp/contrib/mounts-vw/config/mounts/resources/example-mount-cluster.yaml_new
kubectl create -f /tmp/kcp/contrib/mounts-vw/config/mounts/resources/example-mount-cluster.yaml_new

kubectl annotate workspace kind-cluster  experimental.tenancy.kcp.io/mount='{"spec":{"ref":{"kind":"KubeCluster","name":"proxy-cluster","apiVersion":"mounts.contrib.kcp.io/v1alpha1"}}}'

echo "export KUBECONFIG=$PWD/../../.kcp/admin.kubeconfig"

echo "Secret String for VCluster is ready: $vclusterSecretString"
echo ""

echo "kubectl create -f vcluster/team1.yaml"
read -n 1 -s
kubectl create -f vcluster/team1.yaml

echo "kubectl create -f vcluster/team2.yaml"
read -n 1 -s
kubectl create -f vcluster/team2.yaml

echo "kubectl ws create team1"
read -n 1 -s
kubectl ws create team1

echo "kubectl ws create team2"
read -n 1 -s
kubectl ws create team2

echo "mount the vcluster to team1"
read -n 1 -s
kubectl annotate workspace team1  experimental.tenancy.kcp.io/mount='{"spec":{"ref":{"kind":"VCluster","name":"virtual-cluster-1","apiVersion":"mounts.contrib.kcp.io/v1alpha1"}}}'

echo "mount the vcluster to team2"
read -n 1 -s
kubectl annotate workspace team2  experimental.tenancy.kcp.io/mount='{"spec":{"ref":{"kind":"VCluster","name":"virtual-cluster-2","apiVersion":"mounts.contrib.kcp.io/v1alpha1"}}}'
