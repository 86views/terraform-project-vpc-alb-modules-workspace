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

