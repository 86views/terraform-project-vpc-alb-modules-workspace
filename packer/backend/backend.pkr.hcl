packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type = string
}

source "amazon-ebs" "backend" {
  region          = var.aws_region
  ami_name        = "three-tier-backend-ubuntu"
  ami_description = "Custom backend AMI with Node.js 22 + PM2 (Ubuntu 22.04 LTS)"

  instance_type = "t3.micro"

  # Ubuntu default SSH user
  ssh_username = "ubuntu"

  # Ubuntu 22.04 LTS (Jammy)
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }

    most_recent = true
    owners      = ["099720109477"] # Canonical
  }

  tags = {
    Name    = "three-tier-backend"
    Project = "three-tier"
    Tier    = "backend"
    OS      = "ubuntu-22.04"
  }

  run_tags = {
    Name    = "packer-builder-backend"
    Project = "three-tier"
  }
}

build {
  sources = ["source.amazon-ebs.backend"]

  # Run setup.sh as ubuntu user (IMPORTANT for NVM)
  provisioner "shell" {
    script = "setup.sh"
    execute_command = "sudo -u ubuntu {{ .Vars }} bash {{ .Path }}"
  }

  post-processor "manifest" {
    output     = "../ami_ids/backend_manifest.json"
    strip_path = true
  }
}
