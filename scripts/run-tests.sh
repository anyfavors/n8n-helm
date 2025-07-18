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

required_helm=$(cat "$SCRIPT_DIR/../.github/helm-version.txt")
current_helm=$(helm version --short --client 2>/dev/null | cut -d'+' -f1)
if [ "$current_helm" != "$required_helm" ]; then
  echo "Warning: Helm $required_helm expected but $current_helm found" >&2
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

# Build chart dependencies
helm dependency build "$CHART_DIR" >/dev/null

# Verify documentation is up to date
if command -v helm-docs >/dev/null; then
  helm-docs >/dev/null
  git diff --exit-code
else
  echo "helm-docs not installed; skipping documentation check" >&2
fi

# Lint and unit test chart
helm lint --strict "$CHART_DIR"
helm unittest "$CHART_DIR"

# Validate schema is up to date
# The generated schema file is removed on exit by the trap above.
if helm plugin list | grep -qw schema-gen; then
  temp_schema=$(mktemp) || { echo "Failed to create temporary file" >&2; exit 1; }
  helm schema-gen "$CHART_DIR"/values.yaml > "$temp_schema"
  jq --indent 4 '.properties.ingress.properties.hosts.items.properties.paths.items.properties.pathType += {"enum": ["ImplementationSpecific", "Prefix", "Exact"]}' "$temp_schema" > "${temp_schema}.tmp"
  mv "${temp_schema}.tmp" "$temp_schema"
  diff -u "$CHART_DIR"/values.schema.json "$temp_schema"
  rm -f "$temp_schema"
fi

# Render templates to ensure they compile
helm template "$CHART_DIR" >/dev/null

