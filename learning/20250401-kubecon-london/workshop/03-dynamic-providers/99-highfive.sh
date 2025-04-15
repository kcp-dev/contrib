#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

source "$(git rev-parse --show-toplevel)/20250401-kubecon-london/workshop/lib/env.sh" "$(cd "$(dirname "$0")" && pwd)"
source "${WORKSHOP_ROOT}/lib/ensure.sh"
source "${WORKSHOP_ROOT}/lib/kubectl.sh"

[[ -f "${WORKSHOP_ROOT}/.checkpoint-02" ]] || { printf "\n\t📜 You need to complete the previous exercise!\n\n" ; exit 1 ; }

# Verify steps for creating the kind cluster.

ensure::eval_with_msg "kind get clusters | grep provider" \
  "kind cluster 'provider' exists!" \
  "kind cluster 'provider' doesn't seem to exist :( Make sure you create it!" \
ensure::exists_in_kubeconfigs_dir "provider.kubeconfig"
export KUBECONFIG="${KUBECONFIGS_DIR}/provider.kubeconfig"
ensure::eval_with_msg "kubectl version" \
  "provider cluster up and running" \
  "provider cluster doesn't seem to be reachable"
ensure::eval_with_msg "kubectl api-resources | grep postgresql.cnpg.io/v1" \
  "PostgreSQL API available in provider cluster" \
  "PostgreSQL API missing in provider cluster. Did you deploy the cloudnative-pg operator?"

# Switch kubeconfig.

ensure::internal_checkscript_kubeconfig
export KUBECONFIG="${KUBECONFIGS_DIR}/internal-checkscript.kubeconfig"

# Verify steps for creating the provider ws.

ensure::ws_use ":root:providers:database"
ensure::apiexport_exists "postgresql.cnpg.io"

# Verify steps for creating consumer.

ensure::ws_use ":root:consumers:pg"
ensure::apibinding_exists "postgresql.cnpg.io"

# Verify api-syncagent is running.
ensure::process_exists "api-syncagent"

# Verify steps for creating the cluster and the database.

ensure::eval_with_msg "kubectl api-resources | grep postgresql.cnpg.io/v1" \
  "PostgreSQL API available in consumer cluster!" \
  "PostgreSQL API missing in consumer cluster.\nTIP: check api-syncagent command line and logs."
ensure::eval_with_msg "kubectl get cluster/kcp" \
  "PostgreSQL cluster 'kcp' found in the consumer workspace!" \
  "PostgreSQL cluster 'kcp' not found. Make sure you create it!"
ensure::eval_with_msg "kubectl wait cluster/kcp '--for=condition=Ready=true' --timeout=0" \
  "PostgreSQL cluster 'kcp' up and running in the consumer workspace!" \
  "PostgreSQL cluster 'kcp' NOT running :(\n\tTIP: use 'kubectl get clusters' to check status of your pgsql clusters"
ensure::eval_with_msg "kubectl get database/db-one" \
  "PostgreSQL database 'db-one' found in the consumer workspace!" \
  "PostgreSQL database 'db-one' not found. Make sure you create it!"
ensure::eval_with_msg "kubectl wait database/db-one '--for=jsonpath={.status.applied}=true' --timeout=0" \
  "PostgreSQL database 'db-one' up and running!" \
  "PostgreSQL database 'db-one' NOT ready :(\n\tTIP: use 'kubectl get databases' to check status of your pgsql databases"

touch "${WORKSHOP_ROOT}/.checkpoint-03"
printf "\n\t🥳 High-five! Move onto the fourth exercise!\n\n"
