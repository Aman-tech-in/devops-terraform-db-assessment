module "network" {
  source = "../../modules/network"

  name_prefix          = var.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  nat_gateway_count    = var.nat_gateway_count
  tags                 = var.tags
}

module "ecs" {
  source = "../../modules/ecs"

  name_prefix           = var.name_prefix
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  private_subnet_ids    = module.network.private_subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
  ecs_security_group_id = module.network.ecs_security_group_id
  cluster_name          = "${var.name_prefix}-cluster"
  aws_region            = var.aws_region
  container_image       = var.ecs_container_image
  container_port        = 80
  task_cpu              = var.ecs_cpu
  task_memory           = var.ecs_memory
  desired_count         = var.ecs_desired_count
  tags                  = var.tags
}

module "rds" {
  source = "../../modules/rds"

  name_prefix             = var.name_prefix
  private_subnet_ids      = module.network.private_subnet_ids
  rds_security_group_id   = module.network.rds_security_group_id
  db_name                 = var.db_name
  db_username             = var.db_username
  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  max_allocated_storage   = var.rds_max_allocated_storage
  backup_retention_period = var.rds_backup_retention_period
  deletion_protection     = var.rds_deletion_protection
  multi_az                = var.rds_multi_az
  skip_final_snapshot     = var.rds_skip_final_snapshot
  tags                    = var.tags
}
