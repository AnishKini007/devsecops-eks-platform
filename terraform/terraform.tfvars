aws_region           = "us-east-1"
environment          = "production"
project_name         = "capstone-devsecops"
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
cluster_version      = "1.28"

# Application Node Group
node_instance_types = ["t3.large"]
node_desired_size   = 3
node_min_size       = 2
node_max_size       = 5

# DevOps Node Group (Jenkins, SonarQube, Nexus, Monitoring, Vault)
devops_node_instance_types = ["t3.xlarge"]
devops_node_desired_size   = 2
devops_node_min_size       = 1
devops_node_max_size       = 3
