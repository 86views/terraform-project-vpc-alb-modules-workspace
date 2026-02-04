data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "frontend" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["three-tier-frontend-ubuntu"]
  }
}

data "aws_ami" "backend" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["three-tier-backend-ubuntu"]
  }
}

data "aws_acm_certificate" "selected" {
  statuses    = ["ISSUED"]
  most_recent = true

  tags = {
    Domain = "oluleye"
    Name   = "oluleye"
  }
}
