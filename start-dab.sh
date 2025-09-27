#!/usr/bin/env bash
set -euo pipefail

# load .env if present
if [ -f .env ]; then
  # shellcheck disable=SC1091
  source .env
fi

# defaults
IMAGE=${DAB_IMAGE:-mcr.microsoft.com/azure-databases/data-api-builder:latest}
CONTAINER_NAME=${DAB_CONTAINER_NAME:-dab}
HOST_PORT=${DAB_PORT:-5000}
CONFIG_FILE=${DAB_CONFIG_FILE:-dab-config.json}
ENTITIES_SCRIPT=${DAB_ENTITIES_SCRIPT:-/app/automate_add_update_entity.sh}

# stop/remove existing container if running
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Stopping existing container: ${CONTAINER_NAME}"
  docker stop "${CONTAINER_NAME}" || true
  docker rm "${CONTAINER_NAME}" || true
fi

echo "Pulling image ${IMAGE}..."
docker pull "${IMAGE}"

# run container with config and entities mounted
docker run -d \
  --name "${CONTAINER_NAME}" \
  --publish "${HOST_PORT}:5000" \
  --mount type=bind,source="$(pwd)/${CONFIG_FILE}",target=/App/dab-config.json,readonly \
  --mount type=bind,source="$(pwd)/entities.json",target=/App/entities.json,readonly \
  --mount type=bind,source="$(pwd)/automate_add_update_entity.sh",target=${ENTITIES_SCRIPT},readonly \
  "${IMAGE}" || {
    echo "Failed to run container"
    exit 1
  }

sleep 2

echo "Container ${CONTAINER_NAME} started (listening on port ${HOST_PORT})."

# optional: run entity automation script
if [ -f "./automate_add_update_entity.sh" ]; then
  chmod +x ./automate_add_update_entity.sh
  ./automate_add_update_entity.sh "http://localhost:${HOST_PORT}" || echo "entities automation returned non-zero"
else
  echo "No automate_add_update_entity.sh found — skipping."
fi
