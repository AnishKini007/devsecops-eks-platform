# Capstone DevSecOps Mega Project

## Production-Grade DevSecOps Ecosystem on AWS EKS

This project implements a comprehensive DevSecOps ecosystem on AWS, integrating CI/CD pipelines, security scanning, monitoring, and secret management for a cloud-native .NET application.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                         Custom VPC (10.0.0.0/16)                       │  │
│  │  ┌─────────────────────┐  ┌─────────────────────┐                     │  │
│  │  │   Public Subnets    │  │   Private Subnets   │                     │  │
│  │  │   (NAT Gateway)     │  │   (EKS Nodes)       │                     │  │
│  │  └─────────────────────┘  └─────────────────────┘                     │  │
│  │                                   │                                     │  │
│  │  ┌────────────────────────────────┴───────────────────────────────┐   │  │
│  │  │                     Amazon EKS Cluster                          │   │  │
│  │  │  ┌──────────────────────────────────────────────────────────┐  │   │  │
│  │  │  │                  DevOps Node Group                        │  │   │  │
│  │  │  │  ┌─────────┐ ┌──────────┐ ┌───────┐ ┌────────────────┐  │  │   │  │
│  │  │  │  │ Jenkins │ │SonarQube │ │ Nexus │ │Prometheus/Graf │  │  │   │  │
│  │  │  │  └─────────┘ └──────────┘ └───────┘ └────────────────┘  │  │   │  │
│  │  │  │  ┌─────────────────┐                                     │  │   │  │
│  │  │  │  │ HashiCorp Vault │                                     │  │   │  │
│  │  │  │  └─────────────────┘                                     │  │   │  │
│  │  │  └──────────────────────────────────────────────────────────┘  │   │  │
│  │  │  ┌──────────────────────────────────────────────────────────┐  │   │  │
│  │  │  │               Application Node Group                      │  │   │  │
│  │  │  │  ┌─────────────────┐  ┌─────────────────────────────────┐│  │   │  │
│  │  │  │  │ .NET App (x3)   │  │  MongoDB StatefulSet (x3)       ││  │   │  │
│  │  │  │  └─────────────────┘  └─────────────────────────────────┘│  │   │  │
│  │  │  └──────────────────────────────────────────────────────────┘  │   │  │
│  │  └────────────────────────────────────────────────────────────────┘   │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🛠️ Tools & Technologies

| Category | Tools |
|----------|-------|
| Cloud Provider | AWS (EKS, VPC, IAM, EBS) |
| Infrastructure as Code | Terraform |
| Container Orchestration | Kubernetes (EKS) |
| CI/CD | Jenkins (on EKS) |
| Code Quality | SonarQube |
| Artifact Management | Nexus Repository |
| Security Scanning | Trivy, Gitleaks |
| Secret Management | HashiCorp Vault |
| Monitoring | Prometheus, Grafana |
| Database | MongoDB |
| Application | .NET 8.0 |
| Version Control | GitHub |

## 📁 Project Structure

```
Capstone-Project/
├── terraform/
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Variable definitions
│   ├── outputs.tf              # Output definitions
│   ├── providers.tf            # Provider configurations
│   └── modules/
│       ├── vpc/                # VPC module
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── eks/                # EKS module
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
├── kubernetes/
│   ├── jenkins/                # Jenkins deployment
│   │   ├── namespace.yaml
│   │   ├── rbac.yaml
│   │   ├── pvc.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   ├── sonarqube/              # SonarQube deployment
│   │   ├── pvc.yaml
│   │   ├── secret.yaml
│   │   ├── postgresql.yaml
│   │   └── deployment.yaml
│   ├── nexus/                  # Nexus deployment
│   │   ├── pvc.yaml
│   │   └── deployment.yaml
│   ├── monitoring/             # Prometheus & Grafana
│   │   ├── namespace.yaml
│   │   ├── prometheus-config.yaml
│   │   ├── prometheus-rbac.yaml
│   │   ├── prometheus-deployment.yaml
│   │   ├── grafana-config.yaml
│   │   ├── grafana-secret.yaml
│   │   └── grafana-deployment.yaml
│   ├── vault/                  # HashiCorp Vault
│   │   ├── namespace.yaml
│   │   ├── rbac.yaml
│   │   ├── configmap.yaml
│   │   ├── service.yaml
│   │   └── statefulset.yaml
│   ├── mongodb/                # MongoDB StatefulSet
│   │   ├── namespace.yaml
│   │   ├── secret.yaml
│   │   ├── configmap.yaml
│   │   ├── service.yaml
│   │   └── statefulset.yaml
│   └── app/                    # Application deployment
│       ├── configmap.yaml
│       ├── secret.yaml
│       ├── deployment.yaml
│       └── network-policy.yaml
├── jenkins/
│   └── pipelines/
│       ├── Jenkinsfile-CI      # CI Pipeline
│       └── Jenkinsfile-CD      # CD Pipeline
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- kubectl
- Helm 3.x
- Docker

### Step 1: Create S3 Backend for Terraform State

```bash
# Create S3 bucket for Terraform state
aws s3api create-bucket \
    --bucket capstone-devsecops-tfstate \
    --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket capstone-devsecops-tfstate \
    --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
    --table-name terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region us-east-1
```

### Step 2: Deploy Infrastructure with Terraform

```bash
cd terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan -out=tfplan

# Apply the configuration
terraform apply tfplan

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name capstone-devsecops-eks-production
```

### Step 3: Deploy Kubernetes Components

```bash
# Deploy Jenkins
kubectl apply -f kubernetes/jenkins/

# Deploy SonarQube
kubectl apply -f kubernetes/sonarqube/

# Deploy Nexus
kubectl apply -f kubernetes/nexus/

# Deploy Monitoring Stack
kubectl apply -f kubernetes/monitoring/

# Deploy Vault
kubectl apply -f kubernetes/vault/

# Deploy MongoDB
kubectl apply -f kubernetes/mongodb/

# Deploy Application
kubectl apply -f kubernetes/app/
```

### Step 4: Initialize Vault

```bash
# Port forward to Vault
kubectl port-forward svc/vault -n vault 8200:8200

# Initialize Vault (save the keys securely!)
vault operator init

# Unseal Vault (requires 3 of 5 keys)
vault operator unseal <key1>
vault operator unseal <key2>
vault operator unseal <key3>

# Login
vault login <root_token>

# Enable Kubernetes auth
vault auth enable kubernetes
```

### Step 5: Access Services

Get LoadBalancer URLs:

```bash
# Jenkins
kubectl get svc jenkins-lb -n devops-tools -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# SonarQube
kubectl get svc sonarqube-lb -n devops-tools -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Grafana
kubectl get svc grafana-lb -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Application
kubectl get svc capstone-dotnet-app-lb -n application -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## 📋 CI Pipeline Stages

1. **Checkout** - Clone repository
2. **Secret Detection (Gitleaks)** - Scan for exposed secrets
3. **File System Scan (Trivy)** - Scan code for vulnerabilities
4. **Restore Dependencies** - .NET restore
5. **Build Application** - .NET build
6. **Unit Tests** - Run unit tests with code coverage
7. **SonarQube Analysis** - Code quality analysis
8. **Quality Gate** - Enforce quality standards
9. **Build Docker Image** - Build container image
10. **Scan Docker Image (Trivy)** - Container vulnerability scan
11. **Push Docker Image** - Push to Docker Hub
12. **Update Kubernetes Manifests** - Update image tags

## 📋 CD Pipeline Stages

1. **Checkout** - Clone repository
2. **Configure AWS & Kubectl** - Setup credentials
3. **Pre-Deployment Validation** - Dry-run manifests
4. **Deploy to Kubernetes** - Apply manifests
5. **Verify Deployment** - Check rollout status
6. **Health Check** - Validate application health

## 🔐 Security Features

- **Gitleaks** - Secret detection in source code
- **Trivy** - File system and container vulnerability scanning
- **SonarQube** - Code quality and security analysis
- **HashiCorp Vault** - Dynamic secret management
- **Network Policies** - Pod-to-pod communication control
- **RBAC** - Role-based access control
- **Pod Security Context** - Non-root containers, read-only filesystem

## 📊 Monitoring & Observability

- **Prometheus** - Metrics collection
- **Grafana** - Visualization dashboards
- **CloudWatch** - AWS-native logging
- **EKS Control Plane Logging** - API server, audit, scheduler logs

## 🔄 Default Credentials (Change Immediately!)

| Service | Username | Password |
|---------|----------|----------|
| Jenkins | admin | admin123 |
| SonarQube | admin | admin |
| Grafana | admin | admin123 |
| MongoDB | root | rootpassword123 |
| PostgreSQL | sonarqube | sonarqube123 |

⚠️ **Important**: Change all default passwords before deploying to production!

## 🧹 Cleanup

```bash
# Delete Kubernetes resources
kubectl delete -f kubernetes/app/
kubectl delete -f kubernetes/mongodb/
kubectl delete -f kubernetes/vault/
kubectl delete -f kubernetes/monitoring/
kubectl delete -f kubernetes/nexus/
kubectl delete -f kubernetes/sonarqube/
kubectl delete -f kubernetes/jenkins/

# Destroy Terraform resources
cd terraform
terraform destroy
```

## 📝 Notes

- All services are deployed with persistent storage using AWS EBS gp3 volumes
- DevOps tools run on dedicated node group with taints/tolerations
- Application runs on separate node group for resource isolation
- Network policies restrict inter-service communication
- HPA configured for automatic application scaling

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License.
