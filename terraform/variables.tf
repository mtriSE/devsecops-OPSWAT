variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "key_pair_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "coffeeshop-key"
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed for access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.27"
}

variable "node_instance_types" {
  description = "EKS node instance types"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_capacity" {
  description = "Desired number of EKS nodes"
  type        = number
  default     = 2
}

variable "node_max_capacity" {
  description = "Maximum number of EKS nodes"
  type        = number
  default     = 4
}

variable "node_min_capacity" {
  description = "Minimum number of EKS nodes"
  type        = number
  default     = 1
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "backup_retention_period" {
  description = "RDS backup retention period"
  type        = number
  default     = 7
}
