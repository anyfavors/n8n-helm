#!/usr/bin/env bash
set -euo pipefail

# Remove any previously generated schema file when the script exits
trap 'rm -f /tmp/generated-values.schema.json' EXIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="$SCRIPT_DIR/../n8n"

if ! command -v helm >/dev/null; then
  echo "helm is required but not installed" >&2
  exit 1
fi

# Install helm-unittest plugin if missing
if helm plugin list | grep -qw unittest; then
  helm plugin update unittest >/dev/null || true
else
  echo "Installing helm-unittest plugin" >&2
  helm plugin install https://github.com/helm-unittest/helm-unittest >/dev/null
fi

# Add bitnami repo for postgresql dependency
helm repo add bitnami https://charts.bitnami.com/bitnami >/dev/null 2>&1 || true
helm repo update >/dev/null || true

# Build chart dependencies
helm dependency build "$CHART_DIR" >/dev/null

# Lint and unit test chart
helm lint --strict "$CHART_DIR"
helm unittest "$CHART_DIR"

# Validate schema is up to date
# The generated schema file is removed on exit by the trap above.
if helm plugin list | grep -qw schema-gen; then
  temp_schema=$(mktemp) || { echo "Failed to create temporary file" >&2; exit 1; }
  helm schema-gen "$CHART_DIR"/values.yaml > "$temp_schema"
  diff -u "$CHART_DIR"/values.schema.json "$temp_schema"
  rm -f "$temp_schema"
fi

# Render templates to ensure they compile
helm template "$CHART_DIR" >/dev/null

