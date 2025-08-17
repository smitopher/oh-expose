#!/usr/bin/env bash
set -euo pipefail

NETWORK_NAME=internal-net
VOLUMES=(pgdata keycloak-data nginx-config pgadmin-data)

if ! podman network exists "$NETWORK_NAME"; then
  podman network create "$NETWORK_NAME"
fi

for v in "${VOLUMES[@]}"; do
  if ! podman volume inspect "$v" >/dev/null 2>&1; then
    podman volume create "$v"
  fi
done
