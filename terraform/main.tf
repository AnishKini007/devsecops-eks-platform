# Main Terraform Configuration for Capstone DevSecOps Project

locals {
  cluster_name = "${var.project_name}-eks-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  cluster_name         = local.cluster_name
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name               = local.cluster_name
  cluster_version            = var.cluster_version
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  node_instance_types        = var.node_instance_types
  node_desired_size          = var.node_desired_size
  node_min_size              = var.node_min_size
  node_max_size              = var.node_max_size
  devops_node_instance_types = var.devops_node_instance_types
  devops_node_desired_size   = var.devops_node_desired_size
  devops_node_min_size       = var.devops_node_min_size
  devops_node_max_size       = var.devops_node_max_size
  environment                = var.environment

  depends_on = [module.vpc]
}

# EBS CSI Driver for persistent volumes
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.25.0-eksbuild.1"
  service_account_role_arn = module.eks.ebs_csi_driver_role_arn
  resolve_conflicts        = "OVERWRITE"

  depends_on = [module.eks]
}

# Create namespaces for different components
resource "kubernetes_namespace" "devops" {
  metadata {
    name = "devops-tools"
    labels = {
      name        = "devops-tools"
      environment = var.environment
    }
  }

  depends_on = [module.eks]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name        = "monitoring"
      environment = var.environment
    }
  }

  depends_on = [module.eks]
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
    labels = {
      name        = "vault"
      environment = var.environment
    }
  }

  depends_on = [module.eks]
}

resource "kubernetes_namespace" "application" {
  metadata {
    name = "application"
    labels = {
      name        = "application"
      environment = var.environment
    }
  }

  depends_on = [module.eks]
}

# Storage Class for GP3 volumes
resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    type      = "gp3"
    encrypted = "true"
    fsType    = "ext4"
  }

  depends_on = [aws_eks_addon.ebs_csi_driver]
}
