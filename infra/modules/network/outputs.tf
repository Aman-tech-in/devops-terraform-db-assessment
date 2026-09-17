output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [for az in var.availability_zones : aws_subnet.public[az].id]
}

output "private_subnet_ids" {
  value = [for az in var.availability_zones : aws_subnet.private[az].id]
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}
