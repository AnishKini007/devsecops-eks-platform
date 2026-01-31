variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EKS cluster will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS cluster"
  type        = list(string)
}

variable "node_instance_types" {
  description = "Instance types for EKS node groups"
  type        = list(string)
}

variable "node_desired_size" {
  description = "Desired number of nodes in EKS node group"
  type        = number
}

variable "node_min_size" {
  description = "Minimum number of nodes in EKS node group"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of nodes in EKS node group"
  type        = number
}

variable "devops_node_instance_types" {
  description = "Instance types for DevOps tools node group"
  type        = list(string)
}

variable "devops_node_desired_size" {
  description = "Desired number of nodes in DevOps node group"
  type        = number
}

variable "devops_node_min_size" {
  description = "Minimum number of nodes in DevOps node group"
  type        = number
}

variable "devops_node_max_size" {
  description = "Maximum number of nodes in DevOps node group"
  type        = number
}

variable "environment" {
  description = "Environment name"
  type        = string
}
