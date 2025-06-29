terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }

  backend "s3" {
    bucket         = "coffeeshop-state-1751114722" # TODO: ../setup-backend.sh will replace this with the actual bucket name
    key            = "terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  name_prefix = "coffeeshop-${terraform.workspace}"
  environment = terraform.workspace

  vpc_cidr = terraform.workspace == "prod" ? "10.0.0.0/16" : "10.1.0.0/16"

  public_subnet_cidrs = terraform.workspace == "prod" ? [
    "10.0.1.0/24",
    "10.0.2.0/24"
    ] : [
    "10.1.1.0/24",
    "10.1.2.0/24"
  ]

  private_subnet_cidrs = terraform.workspace == "prod" ? [
    "10.0.10.0/24",
    "10.0.11.0/24"
    ] : [
    "10.1.10.0/24",
    "10.1.11.0/24"
  ]

  common_tags = {
    Project     = "coffeeshop"
    Environment = terraform.workspace
    ManagedBy   = "terraform"
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = local.vpc_cidr
  public_subnet_cidrs  = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs
  enable_nat_gateway   = terraform.workspace == "prod"
  cluster_name         = local.name_prefix

  tags = local.common_tags
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security-groups"

  name_prefix   = local.name_prefix
  environment   = local.environment
  vpc_id        = module.vpc.vpc_id
  vpc_cidr      = module.vpc.vpc_cidr_block
  allowed_cidrs = var.allowed_cidrs

  tags = local.common_tags
}

# EC2 Module for Development
module "ec2_dev" {
  count  = terraform.workspace == "dev" ? 1 : 0
  source = "./modules/ec2"

  name_prefix        = local.name_prefix
  instance_type      = var.instance_type
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.security_groups.dev_security_group_id]
  key_name           = var.key_pair_name

  tags = local.common_tags
}

# EKS Module for Production
module "eks" {
  count  = terraform.workspace == "prod" ? 1 : 0
  source = "./modules/eks"

  cluster_name              = local.name_prefix
  cluster_version           = var.cluster_version
  subnet_ids                = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  node_subnet_ids           = module.vpc.private_subnet_ids
  cluster_security_group_id = module.security_groups.eks_cluster_security_group_id
  node_security_group_ids   = [module.security_groups.eks_nodes_security_group_id]

  node_instance_types   = var.node_instance_types
  node_desired_capacity = var.node_desired_capacity
  node_max_capacity     = var.node_max_capacity
  node_min_capacity     = var.node_min_capacity

  tags = local.common_tags
}

# RDS Module for Production
module "rds" {
  count  = terraform.workspace == "prod" ? 1 : 0
  source = "./modules/rds"

  identifier              = "${local.name_prefix}-db"
  db_name                 = "coffeeshop"
  username                = "postgres"
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  subnet_ids              = module.vpc.private_subnet_ids
  security_group_ids      = [module.security_groups.rds_security_group_id]
  backup_retention_period = var.backup_retention_period

  tags = local.common_tags
}

# Data source for AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
