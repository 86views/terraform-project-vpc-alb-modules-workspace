#!/bin/bash
set -euo pipefail

if [ -z "${AWS_REGION:-}" ]; then
  echo "❌ Error: AWS_REGION is not set. Please export AWS_REGION."
  exit 1
fi

AMI_DIR="../ami_ids"
AMI_FILE="$AMI_DIR/frontend_ami.txt"
LOG_FILE="packer_frontend_build.log"

mkdir -p "$AMI_DIR"

echo "🚀 Initializing Packer..."
packer init .

echo "🏗️  Building Frontend AMI for region: $AWS_REGION"

AMI_ID=$(packer build \
  -machine-readable \
  -var "aws_region=$AWS_REGION" \
  frontend.pkr.hcl \
  | tee "$LOG_FILE" \
  | awk -F, '$0 ~/artifact,0,id/ {print $6}' \
  | cut -d: -f2
)

if [ -n "$AMI_ID" ]; then
  echo "✅ Frontend AMI created: $AMI_ID"
  echo -n "$AMI_ID" > "$AMI_FILE"
else
  echo "❌ Failed to build frontend AMI"
  exit 1
fi
