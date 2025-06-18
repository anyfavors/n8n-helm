#!/usr/bin/env bash
set -euo pipefail

if ! command -v helm-docs >/dev/null 2>&1; then
  echo "Error: helm-docs command not found." >&2
  echo "Install helm-docs from https://github.com/norwoodj/helm-docs/releases and ensure it is in your PATH." >&2
  exit 1
fi

helm-docs

git diff --exit-code
