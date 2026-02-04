# --- Infrastructure Inputs (Usually passed from VPC/Packer) ---
variable "image_id" {
  type        = string
  description = "The AMI ID from Packer"
}

variable "subnet_id" {
  type        = string
  description = "The Public Subnet ID from the VPC module"
}

variable "security_groups" {
  type        = list(string)
  description = "The SG ID allowing SSH access"
}

# --- Instance Configuration ---
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "tags" {
  type    = map(string)
  default = {}
}

# --- SSH Key Logic ---
variable "key_pair_name" {
  description = "Prefix for the AWS Key Pair name"
  type        = string
  default     = "bastion-setup-key" # Fixed typo from 'baston'
}

variable "ssh_private_key_path" {
  description = "Local path where the .pem file will be saved"
  type        = string
  default     = "/home/oluseun/projects/terraform-project-vpc-alb-modules-workspace/config/bastion-key.pem"
}