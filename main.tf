data "aws_ami" "frontend" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["three-tier-frontend-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

module "vpc" {
  source             = "./modules/vpc"
  cidr_block         = "10.75.0.0/16"
  alb_subnet_public  = ["10.75.1.0/24", "10.75.2.0/24", "10.75.3.0/24"]
  web_subnet_private = ["10.75.4.0/24", "10.75.5.0/24", "10.75.6.0/24"]
  app_subnet_private = ["10.75.7.0/24", "10.75.8.0/24", "10.75.9.0/24"]
  db_subnet_private  = ["10.75.10.0/24", "10.75.11.0/24", "10.75.12.0/24"]

  tags = {
    Name = "vpc-alb"
  }
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "rds" {
  source = "./modules/rds"

  instance_class = var.db_instance_class
  engine         = var.db_engine
  engine_version = var.db_engine_version

  parameter_group_name = var.db_parameter_group_name

  storage_encrypted = var.storage_encrypted
  allocated_storage = var.db_allocated_storage
  storage_type      = var.db_storage_type

  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [module.sg.db_sg_id]
  subnet_ids             = module.vpc.db_subnet_private

  multi_az            = var.multi_az
  publicly_accessible = var.publicly_accessible

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  skip_final_snapshot          = var.skip_final_snapshot
  deletion_protection          = var.deletion_protection
  apply_immediately            = var.apply_immediately
  performance_insights_enabled = var.performance_insights_enabled

}

module "secrets" {
  source      = "./modules/secrets"
  secret_name = "backend-db-credentials-${terraform.workspace}"
  db_username = var.db_username
  db_password = var.db_password
  db_endpoint = module.rds.db_instance_endpoint
}

module "asg" {
  source = "./modules/asg"

  vpc_id              = module.vpc.vpc_id
  public_subnets      = module.vpc.alb_subnet_public
  web_private_subnets = module.vpc.web_subnet_private
  app_private_subnets = module.vpc.app_subnet_private

  frontend_alb_sg_id = module.sg.frontend_alb_sg_id
  backend_alb_sg_id  = module.sg.app_alb_internal_sg_id

  # Using dynamic AMI from data source
  image_id          = data.aws_ami.frontend.id
  web_instance_type = "t2.micro"
  app_instance_type = "t2.micro"
  user_data_base64  = base64encode(file("user_data.sh"))

  sns_topic_arn = "arn:aws:sns:ap-south-1:970378220457:stale-ebs"
}

module "route53" {
  source           = "./modules/route53"
  hosted_zone_name = "harishshetty.xyz"
  record_name      = "dev"
  alb_dns_name     = module.asg.web_alb_dns_name
  alb_zone_id      = module.asg.web_alb_zone_id
}
