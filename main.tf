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

  instance_class = "db.t2.micro"
  engine         = "mysql"
  engine_version = "8.0"

  parameter_group_name = "default.mysql8.0"

  storage_encrypted = false
  allocated_storage = 20
  storage_type      = "gp3"

  username = "admin"
  password = "password"

  vpc_security_group_ids = [module.sg.db_sg_id]
  subnet_ids             = module.vpc.db_subnet_private

  multi_az            = false
  publicly_accessible = false

  backup_retention_period = 7
  backup_window           = "03:00-05:00"
  maintenance_window      = "sun:05:00-sun:06:00"

  skip_final_snapshot          = true
  deletion_protection          = false
  apply_immediately            = true
  performance_insights_enabled = true

}

module "secrets" {
  source      = "./modules/secrets"
  secret_name = "backend-db-credentials-${terraform.workspace}"
  db_username = "admin"
  db_password = "password"
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

  # Using hardcoded values as they are not defined in root variables
  image_id          = "ami-00bb6a80f01f03502" # Ubuntu 22.04 in ap-south-1 (example)
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
