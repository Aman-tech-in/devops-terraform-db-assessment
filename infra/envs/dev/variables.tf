variable "aws_region" {
  type = string
}

variable "plan_only" {
  description = "When true, configure the AWS provider for credential-free plan review. Set false for real deployment with AWS credentials."
  type        = bool
  default     = true
}

variable "name_prefix" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "nat_gateway_count" {
  type = number
}

variable "ecs_cpu" {
  type = number
}

variable "ecs_memory" {
  type = number
}

variable "ecs_desired_count" {
  type = number
}

variable "ecs_container_image" {
  type = string
}

variable "rds_instance_class" {
  type = string
}

variable "rds_allocated_storage" {
  type = number
}

variable "rds_max_allocated_storage" {
  type = number
}

variable "rds_backup_retention_period" {
  type = number
}

variable "rds_deletion_protection" {
  type = bool
}

variable "rds_multi_az" {
  type = bool
}

variable "rds_skip_final_snapshot" {
  type = bool
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
# Testing GitHub Actions Terraform workflow
