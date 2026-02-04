#!/bin/bash
set -euo pipefail

# -----------------------------
# Environment
# -----------------------------
export AWS_REGION="${AWS_REGION:-us-east-1}"

FRONTEND_AMI_NAME="three-tier-frontend-ubuntu"
BACKEND_AMI_NAME="three-tier-backend-ubuntu"

echo "🌍 Using AWS region: $AWS_REGION"

# -----------------------------
# Function: check AMI existence
# -----------------------------
check_ami_exists() {
  local ami_name=$1

  echo "🔍 Checking for AMI: $ami_name"

  local ami_id
  ami_id=$(aws ec2 describe-images \
    --owners self \
    --filters \
      "Name=name,Values=$ami_name" \
      "Name=state,Values=available" \
    --query "Images | sort_by(@, &CreationDate)[-1].ImageId" \
    --output text \
    --region "$AWS_REGION"
  )

  if [ "$ami_id" != "None" ] && [ -n "$ami_id" ]; then
    echo "✅ Found AMI: $ami_name → $ami_id"
    return 0
  else
    echo "❌ AMI not found: $ami_name"
    return 1
  fi
}

# -----------------------------
# Frontend AMI
# -----------------------------
if ! check_ami_exists "$FRONTEND_AMI_NAME"; then
  echo "🏗️  Building Frontend AMI..."
  (
    cd packer/frontend
    ./build_ami.sh
  )
else
  echo "⏭️  Skipping Frontend AMI build."
fi

# -----------------------------
# Backend AMI
# -----------------------------
if ! check_ami_exists "$BACKEND_AMI_NAME"; then
  echo "🏗️  Building Backend AMI..."
  (
    cd packer/backend
    ./build_ami.sh
  )
else
  echo "⏭️  Skipping Backend AMI build."
fi

echo "🚀 All AMIs are ready. Proceeding with Terraform..."

# -----------------------------
# Terraform
# -----------------------------
terraform init
terraform apply \
  -var-file="staging.tfvars" \
  -auto-approve
