#!/bin/sh
set -eu

KIBANA_URL=${KIBANA_URL:-http://kibana:5601}
SAVED_OBJECTS_PATH=${SAVED_OBJECTS_PATH:-/usr/share/kibana/saved_objects/snort.ndjson}

until curl -sSf "${KIBANA_URL}/api/status" >/dev/null; do
  echo "Waiting for Kibana..."
  sleep 5
done

curl -sSf -X POST "${KIBANA_URL}/api/saved_objects/_import?overwrite=true" \
  -H "kbn-xsrf: true" \
  --form file=@"${SAVED_OBJECTS_PATH}"

curl -sSf -X POST "${KIBANA_URL}/api/kibana/settings/defaultIndex" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{"value":"snort-alerts"}'

echo "Kibana saved objects imported."
