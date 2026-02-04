resource "random_id" "suffix" {
  byte_length = 4
  keepers = {
    regenerate = "v1"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Generate private key
resource "tls_private_key" "bastion_key" { # ← renamed for consistency
  algorithm = "ED25519"
}

resource "aws_key_pair" "bastion_kp" {
  key_name   = "${var.key_pair_name}-${random_id.suffix.hex}"
  public_key = tls_private_key.bastion_key.public_key_openssh
}

# Save private key to local file
resource "local_file" "bastion_pem" { # ← renamed for clarity (was "nodejs_pem")
  content         = tls_private_key.bastion_key.private_key_openssh
  filename        = var.ssh_private_key_path
  file_permission = "0400"
}

# 2. THE INSTANCE (References the generator above)
resource "aws_instance" "bastion" {
  ami                    = var.image_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_groups
  tags                   = var.tags

  # This is the "Wire": It pulls the name directly from the resource above
  key_name               = aws_key_pair.bastion_kp.key_name 
}
