#!/bin/bash
set -euo pipefail

echo "🔍 Running tfsec..."
if ! command -v tfsec >/dev/null 2>&1; then
  echo "tfsec not found - installing..."
  curl -sSL -o /usr/local/bin/tfsec https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-amd64
  chmod +x /usr/local/bin/tfsec
fi

cd "$(dirname "$0")/../terraform"
tfsec --format json --out ../tfsec-report.json || true
echo "tfsec done. Report: tfsec-report.json"
