output "dev_security_group_id" {
  description = "ID of the development security group"
  value       = var.environment == "dev" ? aws_security_group.dev[0].id : null
}

output "eks_cluster_security_group_id" {
  description = "ID of the EKS cluster security group"
  value       = var.environment == "prod" ? aws_security_group.eks_cluster[0].id : null
}

output "eks_nodes_security_group_id" {
  description = "ID of the EKS nodes security group"
  value       = var.environment == "prod" ? aws_security_group.eks_nodes[0].id : null
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = var.environment == "prod" ? aws_security_group.rds[0].id : null
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = var.environment == "prod" ? aws_security_group.alb[0].id : null
}
