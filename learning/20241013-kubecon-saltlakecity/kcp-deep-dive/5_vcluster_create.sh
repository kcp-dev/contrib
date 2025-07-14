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
current_dir=$(pwd)

cd "$temp_dir/contrib/mounts-vw"
export KUBECONFIG=$PWD/../../.kcp/admin.kubeconfig

kubectl ws use :root:operators:mounts > /dev/null 2>&1

# Initialize the variable as empty
export kubeSecretString=""

# Loop until kubeSecretString is not empty
while [[ -z "$kubeSecretString" ]]; do
  # Run the kubectl command and assign the result to the variable
  kubeSecretString=$(kubectl get TargetKubeCluster proxy-cluster -o jsonpath='{.status.secretString}')

  # Wait for a short period before checking again to avoid excessive requests
  sleep 2
done

# Print the result or proceed with your next steps
# echo "Secret String for KubeCluster is ready: $kubeSecretString"

# Initialize the variable as empty
export vclusterSecretString=""

# Loop until kubeSecretString is not empty
while [[ -z "$vclusterSecretString" ]]; do
  # Run the kubectl command and assign the result to the variable
  vclusterSecretString=$(kubectl get TargetVCluster proxy-cluster -o jsonpath='{.status.secretString}')

  # Wait for a short period before checking again to avoid excessive requests
  sleep 2
done

# Print the result or proceed with your next steps
# echo "Secret String for VCluster is ready: $vclusterSecretString"

# Create a consumer workspace for mounts:

# echo "Create consumer workspace for mounts"
kubectl ws use :root > /dev/null 2>&1
kubectl create workspace consumer > /dev/null 2>&1
kubectl ws use consumer > /dev/null 2>&1
kubectl create workspace kind-cluster > /dev/null 2>&1

kubectl create -f config/mounts/resources/apibinding-mounts.yaml > /dev/null 2>&1

cat /tmp/kcp/contrib/mounts-vw/config/mounts/resources/example-mount-cluster.yaml | yq '.spec.secretString=env(kubeSecretString)' - > /tmp/kcp/contrib/mounts-vw/config/mounts/resources/example-mount-cluster.yaml_new

# cat /tmp/kcp/contrib/mounts-vw/config/mounts/resources/example-mount-cluster.yaml_new
kubectl create -f /tmp/kcp/contrib/mounts-vw/config/mounts/resources/example-mount-cluster.yaml_new > /dev/null 2>&1

kubectl annotate workspace kind-cluster  experimental.tenancy.kcp.io/mount='{"spec":{"ref":{"kind":"KubeCluster","name":"proxy-cluster","apiVersion":"mounts.contrib.kcp.io/v1alpha1"}}}' > /dev/null 2>&1

#echo "export KUBECONFIG=$PWD/../../.kcp/admin.kubeconfig"

echo "let's create vclusters and observe... "
echo ""
read -n 1 -s

echo "kubectl create -f vcluster/team1.yaml"
read -n 1 -s
cat $current_dir/vcluster/team1.yaml | yq '.spec.secretString=env(vclusterSecretString)' - > /tmp/vluster-team1.yaml
kubectl create -f /tmp/vluster-team1.yaml


echo "kubectl create -f /tmp/vluster-team2.yaml"
read -n 1 -s
cat $current_dir/vcluster/team2.yaml | yq '.spec.secretString= env(vclusterSecretString)' - > /tmp/vluster-team2.yaml
kubectl create -f /tmp/vluster-team2.yaml

echo "Now we have 2 vclusters, let's create workspaces for team1 and team2"
echo ""

echo "kubectl create workspace team1"
read -n 1 -s
kubectl create workspace team1

echo "kubectl create workspace team2"
read -n 1 -s
kubectl create workspace team2

echo "Let's see that before we mount the vclusters to the workspaces, its just a normal workspace"

echo "mount the vcluster to team1"
read -n 1 -s
kubectl annotate workspace team1  experimental.tenancy.kcp.io/mount='{"spec":{"ref":{"kind":"VCluster","name":"team-1","apiVersion":"mounts.contrib.kcp.io/v1alpha1"}}}' --overwrite

echo "mount the vcluster to team2"
read -n 1 -s
kubectl annotate workspace team2  experimental.tenancy.kcp.io/mount='{"spec":{"ref":{"kind":"VCluster","name":"team-2","apiVersion":"mounts.contrib.kcp.io/v1alpha1"}}}' --overwrite
