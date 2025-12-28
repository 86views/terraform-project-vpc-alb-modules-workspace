variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "web_private_subnets" {
  type = list(string)
}

variable "app_private_subnets" {
  type = list(string)
}

variable "frontend_alb_sg_id" {
  type = string
}

variable "backend_alb_sg_id" {
  type = string
}

variable "web_instance_type" {
  type = string
}

variable "app_instance_type" {
  type = string
}

variable "image_id" {
  type = string
}

variable "user_data_base64" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}
