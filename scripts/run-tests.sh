#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="$SCRIPT_DIR/../n8n"

if ! command -v helm >/dev/null; then
  echo "helm is required but not installed" >&2
  exit 1
fi

# Install helm-unittest plugin if missing
if helm plugin list | grep -q '^unittest'; then
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
if helm plugin list | grep -q '^schema-gen'; then
  helm schema-gen "$CHART_DIR"/values.yaml > /tmp/generated-values.schema.json
  diff -u "$CHART_DIR"/values.schema.json /tmp/generated-values.schema.json
fi

# Render templates to ensure they compile
helm template "$CHART_DIR" >/dev/null

