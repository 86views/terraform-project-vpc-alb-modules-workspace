#!/bin/bash
set -e

AWS_REGION="${AWS_REGION:-ap-south-1}"
AMI_FILE="../ami_ids/backend_ami.txt"
mkdir -p ../ami_ids
LOG_FILE="packer_build.log"

packer init .
AMI_ID=$(packer build -machine-readable -var aws_region=$AWS_REGION backend.pkr.hcl | tee /dev/tty | awk -F, '$0 ~/artifact,0,id/ {print $6}' | cut -d: -f2)

if [ -n "$AMI_ID" ]; then
  echo "Backend AMI created: $AMI_ID"
  echo -n "$AMI_ID" > $AMI_FILE
else
  echo "Failed to build backend AMI"
  exit 1
fi
