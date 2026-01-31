#!/bin/bash

# Deploy All Kubernetes Components
# Run this script after Terraform has provisioned the EKS cluster

set -e

echo "=========================================="
echo "Capstone DevSecOps - Kubernetes Deployment"
echo "=========================================="

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo "Error: kubectl is not configured. Please run:"
    echo "aws eks update-kubeconfig --region us-east-1 --name capstone-devsecops-eks-production"
    exit 1
fi

echo ""
echo "Step 1: Deploying Jenkins..."
kubectl apply -f kubernetes/jenkins/namespace.yaml
kubectl apply -f kubernetes/jenkins/rbac.yaml
kubectl apply -f kubernetes/jenkins/pvc.yaml
kubectl apply -f kubernetes/jenkins/configmap.yaml
kubectl apply -f kubernetes/jenkins/deployment.yaml
kubectl apply -f kubernetes/jenkins/service.yaml
echo "Jenkins deployed successfully!"

echo ""
echo "Step 2: Deploying SonarQube..."
kubectl apply -f kubernetes/sonarqube/secret.yaml
kubectl apply -f kubernetes/sonarqube/pvc.yaml
kubectl apply -f kubernetes/sonarqube/postgresql.yaml
echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/sonarqube-postgresql -n devops-tools
kubectl apply -f kubernetes/sonarqube/deployment.yaml
echo "SonarQube deployed successfully!"

echo ""
echo "Step 3: Deploying Nexus..."
kubectl apply -f kubernetes/nexus/pvc.yaml
kubectl apply -f kubernetes/nexus/deployment.yaml
echo "Nexus deployed successfully!"

echo ""
echo "Step 4: Deploying Monitoring Stack..."
kubectl apply -f kubernetes/monitoring/namespace.yaml
kubectl apply -f kubernetes/monitoring/prometheus-rbac.yaml
kubectl apply -f kubernetes/monitoring/prometheus-config.yaml
kubectl apply -f kubernetes/monitoring/prometheus-deployment.yaml
kubectl apply -f kubernetes/monitoring/grafana-config.yaml
kubectl apply -f kubernetes/monitoring/grafana-secret.yaml
kubectl apply -f kubernetes/monitoring/grafana-deployment.yaml
echo "Monitoring stack deployed successfully!"

echo ""
echo "Step 5: Deploying HashiCorp Vault..."
kubectl apply -f kubernetes/vault/namespace.yaml
kubectl apply -f kubernetes/vault/rbac.yaml
kubectl apply -f kubernetes/vault/configmap.yaml
kubectl apply -f kubernetes/vault/service.yaml
kubectl apply -f kubernetes/vault/statefulset.yaml
echo "Vault deployed successfully!"

echo ""
echo "Step 6: Deploying MongoDB..."
kubectl apply -f kubernetes/mongodb/namespace.yaml || true
kubectl apply -f kubernetes/mongodb/secret.yaml
kubectl apply -f kubernetes/mongodb/configmap.yaml
kubectl apply -f kubernetes/mongodb/service.yaml
kubectl apply -f kubernetes/mongodb/statefulset.yaml
echo "MongoDB deployed successfully!"

echo ""
echo "Step 7: Deploying Application..."
kubectl apply -f kubernetes/app/configmap.yaml
kubectl apply -f kubernetes/app/secret.yaml
kubectl apply -f kubernetes/app/deployment.yaml
kubectl apply -f kubernetes/app/network-policy.yaml
echo "Application deployed successfully!"

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Waiting for LoadBalancers to be assigned..."
sleep 30

echo ""
echo "Service URLs:"
echo "============="
echo "Jenkins: http://$(kubectl get svc jenkins-lb -n devops-tools -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo 'pending...')"
echo "SonarQube: http://$(kubectl get svc sonarqube-lb -n devops-tools -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo 'pending...')"
echo "Nexus: http://$(kubectl get svc nexus-lb -n devops-tools -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo 'pending...')"
echo "Prometheus: http://$(kubectl get svc prometheus-lb -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo 'pending...')"
echo "Grafana: http://$(kubectl get svc grafana-lb -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo 'pending...')"
echo "Vault: http://$(kubectl get svc vault-lb -n vault -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo 'pending...')"
echo "Application: http://$(kubectl get svc capstone-dotnet-app-lb -n application -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo 'pending...')"
echo ""
echo "Note: It may take a few minutes for LoadBalancer DNS to propagate."
