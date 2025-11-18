#!/bin/bash
set -euo pipefail

echo "🔍 Running Checkov..."
if ! command -v checkov >/dev/null 2>&1; then
  echo "Checkov not found - installing via pip..."
  pip3 install --no-cache-dir checkov
fi

cd "$(dirname "$0")/../terraform"
checkov -d . -o json > ../checkov-report.json || true
echo "checkov done. Report: checkov-report.json"
