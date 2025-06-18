#!/usr/bin/env bash
set -euo pipefail

CHART_DIR="n8n"
SCHEMA_FILE="generated-values.schema.json"

if ! command -v helm >/dev/null 2>&1; then
  echo "Error: helm command not found." >&2
  exit 1
fi

# Check for schema-gen plugin
if ! helm plugin list | grep -qw schema-gen; then
  echo "Error: helm schema-gen plugin not installed." >&2
  echo "Install with: helm plugin install https://github.com/karuppiah7890/helm-schema-gen.git" >&2
  exit 1
fi

helm schema-gen "$CHART_DIR/values.yaml" > "$SCHEMA_FILE"
diff -u "$CHART_DIR/values.schema.json" "$SCHEMA_FILE"
