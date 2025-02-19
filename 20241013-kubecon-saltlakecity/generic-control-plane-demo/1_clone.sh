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

# Clone the git repository into the fixed temporary directory
echo "Step 1: Cloning the repository into the fixed temporary directory..."
rm -rf "$temp_dir"  # Ensure the directory is clean before cloning
git clone https://github.com/kcp-dev/generic-controlplane "$temp_dir"
echo "Repository cloned into $temp_dir."
