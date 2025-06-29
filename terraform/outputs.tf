output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "dev_instance_public_ip" {
  description = "Development instance public IP"
  value       = terraform.workspace == "dev" ? module.ec2_dev[0].public_ip : null
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = terraform.workspace == "prod" ? module.eks[0].cluster_endpoint : null
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = terraform.workspace == "prod" ? module.eks[0].cluster_name : null
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = terraform.workspace == "prod" ? module.rds[0].endpoint : null
}
