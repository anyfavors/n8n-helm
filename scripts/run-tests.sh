#!/usr/bin/env bash
set -euo pipefail

CHART_DIR="$(dirname "$0")/../n8n"

if ! command -v helm >/dev/null; then
  echo "helm is required but not installed" >&2
  exit 1
fi

# Install helm-unittest plugin if missing
if ! helm plugin list | grep -q '^unittest'; then
  echo "Installing helm-unittest plugin" >&2
  helm plugin install https://github.com/helm-unittest/helm-unittest >/dev/null
fi

# Add bitnami repo for postgresql dependency
if ! helm repo list | grep -q "bitnami"; then
  helm repo add bitnami https://charts.bitnami.com/bitnami >/dev/null
fi
helm repo update >/dev/null

# Build chart dependencies
helm dependency build "$CHART_DIR" >/dev/null

# Lint and unit test chart
helm lint "$CHART_DIR"
helm unittest "$CHART_DIR"

# Validate schema is up to date
if helm plugin list | grep -q helm-schema; then
  helm schema-gen "$CHART_DIR"/values.yaml > /tmp/generated-values.schema.json
  diff -u "$CHART_DIR"/values.schema.json /tmp/generated-values.schema.json
fi

# Render templates to ensure they compile
helm template "$CHART_DIR" >/dev/null

