#!/bin/bash
set -euo pipefail

# This script does a terraform apply. Use only on approved runs.
cd "$(dirname "$0")/../terraform"
terraform init -input=false
terraform apply -input=false -auto-approve
