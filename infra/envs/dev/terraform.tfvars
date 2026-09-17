aws_region = "us-east-1"
plan_only  = true

name_prefix = "booking-dev"
vpc_cidr    = "10.10.0.0/16"

availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
nat_gateway_count    = 1

ecs_cpu             = 256
ecs_memory          = 512
ecs_desired_count   = 1
ecs_container_image = "nginx:1.27-alpine"

rds_instance_class          = "db.t3.micro"
rds_allocated_storage       = 20
rds_max_allocated_storage   = 50
rds_backup_retention_period = 3
rds_deletion_protection     = false
rds_multi_az                = false
rds_skip_final_snapshot     = true

db_name     = "bookingdb"
db_username = "app_user"

tags = {
  Project     = "devops-assessment"
  Environment = "dev"
  ManagedBy   = "terraform"
}
