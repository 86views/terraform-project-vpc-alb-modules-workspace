region             = "us-east-1"
vpc_cidr_block     = "192.168.0.0/16"
alb_subnet_public  = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
web_subnet_private = ["192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]
app_subnet_private = ["192.168.7.0/24", "192.168.8.0/24", "192.168.9.0/24"]
db_subnet_private  = ["192.168.10.0/24", "192.168.11.0/24", "192.168.12.0/24"]

web_instance_type = "t3.micro"
app_instance_type = "t3.micro"

db_instance_class       = "db.t4g.micro"
db_engine               = "mysql"
db_engine_version       = "8.0"
db_parameter_group_name = "default.mysql8.0"
storage_encrypted       = false
db_allocated_storage    = 20
db_storage_type         = "gp3"
db_username             = "admin"
db_password             = "GOODman0011"
db_name                 = "webappdb"

multi_az            = true
publicly_accessible = false

backup_retention_period = 7
backup_window           = "03:00-05:00"
maintenance_window      = "sun:07:00-sun:09:00"

skip_final_snapshot          = true
deletion_protection          = false
apply_immediately            = true
performance_insights_enabled = false

secret_username = "admin"
secret_password = "GOODman0011"
secret_db_name  = "webappdb"

desired_capacity_web = 1
min_size_web         = 1
max_size_web         = 2

desired_capacity_app = 2
min_size_app         = 2
max_size_app         = 4

sns_topic_arn = "arn:aws:sns:us-east-1:173331852212:sns-route-alb-notifications" # create your own sns topic


hosted_zone_name = "oluleye.xyz" # create your own hosted zone
record_name      = "staging"



bastion_image_id      = "ami-0b6c6ebed2801a5cb" # change this to your own ami id
bastion_instance_type = "t3.micro"
bastion_tags          = { Name = "bastion-dev" }
bastion_key_name = "dev-bastion-key"
ssh_private_key_path = "./config/dev-bastion-key.pem"

tags = {
  Project     = "vpc-alb"
  Environment = "dev"
}
