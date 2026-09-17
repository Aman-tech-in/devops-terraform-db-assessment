output "vpc_id" {
  value = module.network.vpc_id
}

output "alb_dns_name" {
  value = module.ecs.load_balancer_dns_name
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}
