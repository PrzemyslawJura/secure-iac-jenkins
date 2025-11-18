#!/bin/bash
set -euo pipefail

echo "🧠 Running terraform init & plan..."
cd "$(dirname "$0")/../terraform"
terraform init -input=false
terraform validate
terraform fmt -check
terraform plan -out ../plan.out -input=false || true
echo "Plan saved to plan.out"
