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

source "amazon-ebs" "frontend" {
  region          = var.aws_region
  ami_name        = "three-tier-frontend-ubuntu"
  ami_description = "Custom frontend AMI with Nginx + Git + Node.js 22 (Ubuntu 22.04 LTS)"

  instance_type = "t3.micro"

  # Ubuntu default SSH user
  ssh_username = "ubuntu"

  # Ubuntu 22.04 LTS (Jammy) – always fetch latest
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true

    # Canonical (official Ubuntu AMI owner)
    owners = ["099720109477"]
  }

  tags = {
    Name    = "three-tier-frontend"
    Project = "three-tier"
    Tier    = "frontend"
    OS      = "ubuntu-22.04"
  }

  run_tags = {
    Name    = "packer-builder-frontend"
    Project = "three-tier"
  }
}

build {
  sources = ["source.amazon-ebs.frontend"]

  provisioner "shell" {
    script = "setup.sh"
  }

  post-processor "manifest" {
    output     = "../ami_ids/frontend_manifest.json"
    strip_path = true
  }
}
