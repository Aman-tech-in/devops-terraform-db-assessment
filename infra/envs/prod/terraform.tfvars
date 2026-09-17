aws_region = "us-east-1"
plan_only  = true

name_prefix = "booking-prod"
vpc_cidr    = "10.20.0.0/16"

availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs = ["10.20.11.0/24", "10.20.12.0/24"]
nat_gateway_count    = 2

ecs_cpu             = 512
ecs_memory          = 1024
ecs_desired_count   = 2
ecs_container_image = "nginx:1.27-alpine"

rds_instance_class          = "db.t3.medium"
rds_allocated_storage       = 50
rds_max_allocated_storage   = 200
rds_backup_retention_period = 14
rds_deletion_protection     = true
rds_multi_az                = true
rds_skip_final_snapshot     = false

db_name     = "bookingdb"
db_username = "app_user"

tags = {
  Project     = "devops-assessment"
  Environment = "prod"
  ManagedBy   = "terraform"
}
