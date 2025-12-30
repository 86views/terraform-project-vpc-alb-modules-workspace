resource "aws_instance" "bastion" {
  ami             = var.image_id
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  security_groups = var.security_groups
  tags            = var.tags
  key_name        = var.key_name
}
