#!/usr/bin/env bash
set -euo pipefail

BASE_URL=${1:-http://localhost:5000}
ENTITIES_FILE=${ENTITIES_FILE:-entities.json}

if [ ! -f "${ENTITIES_FILE}" ]; then
  echo "Entities file '${ENTITIES_FILE}' not found. Exiting."
  exit 0
fi

# Loop through entities.json (expects it to be an array of JSON objects)
jq -c '.[]' "${ENTITIES_FILE}" | while read -r entity; do
  echo "Processing entity: ${entity}"

  # Example placeholder: if DAB exposed an endpoint for entities
  # curl -sSf -X POST "$BASE_URL/admin/entities" \
  #   -H "Content-Type: application/json" \
  #   -d "$entity"

  # Fallback: save each entity as its own JSON file
  echo "$entity" > "./.generated_entity_$(date +%s).json"
done

echo "Entities processed. If you expected DAB to pick them up, ensure they are merged into dab-config.json and restart DAB."
