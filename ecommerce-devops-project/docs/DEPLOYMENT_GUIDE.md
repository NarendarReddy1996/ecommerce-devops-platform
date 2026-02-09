# Deployment Guide

## Phase 1: Local Development (Week 1-2)

### Step 1: Set Up Local Environment

1. **Install prerequisites**
```bash
# macOS
brew install docker docker-compose kubectl terraform

# Ubuntu
sudo apt-get update
sudo apt-get install docker.io docker-compose kubectl
```

2. **Clone and start**
```bash
git clone <your-repo>
cd ecommerce-devops-project
docker-compose up -d
```

3. **Verify services**
```bash
# Check all containers are running
docker-compose ps

# Test endpoints
curl http://localhost:3001/health  # Product Service
curl http://localhost:3002/actuator/health  # User Service
curl http://localhost:3003/health  # Order Service
curl http://localhost:3004/health  # Payment Service
```

### Step 2: Seed Test Data

```bash
# Create sample products
for i in {1..5}; do
  curl -X POST http://localhost:3001/api/products \
    -H "Content-Type: application/json" \
    -d "{
      \"name\": \"Product $i\",
      \"description\": \"Description for product $i\",
      \"price\": $((100 + i * 50)),
      \"category\": \"Electronics\",
      \"stock\": $((10 + i * 5))
    }"
done
```

---

## Phase 2: Cloud Infrastructure Setup (Week 3-4)

### AWS Account Setup

1. **Create AWS account and configure CLI**
```bash
aws configure
# Enter: Access Key, Secret Key, Region (us-east-1), Output format (json)
```

2. **Create S3 bucket for Terraform state**
```bash
aws s3api create-bucket \
  --bucket ecommerce-terraform-state \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket ecommerce-terraform-state \
  --versioning-configuration Status=Enabled
```

3. **Create DynamoDB table for state locking**
```bash
aws dynamodb create-table \
  --table-name terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### Infrastructure Deployment

1. **Navigate to Terraform directory**
```bash
cd infrastructure/terraform
```

2. **Create terraform.tfvars**
```bash
cat > terraform.tfvars <<EOF
aws_region = "us-east-1"
environment = "prod"
project_name = "ecommerce"
vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
kubernetes_version = "1.28"
db_username = "admin"
db_password = "YourSecurePassword123!"
EOF
```

3. **Initialize and deploy**
```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

4. **Save outputs**
```bash
terraform output > outputs.txt
```

---

## Phase 3: Kubernetes Cluster Setup (Week 5-6)

### Configure kubectl

```bash
# Get cluster name from Terraform outputs
aws eks update-kubeconfig \
  --name ecommerce-prod \
  --region us-east-1

# Verify connection
kubectl cluster-info
kubectl get nodes
```

### Install Essential Add-ons

1. **Metrics Server**
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

2. **NGINX Ingress Controller**
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/aws/deploy.yaml
```

3. **Cert-Manager (SSL certificates)**
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

4. **Prometheus & Grafana (Helm)**
```bash
# Add Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

### Deploy Application

1. **Create namespace**
```bash
kubectl apply -f infrastructure/kubernetes/namespace.yaml
```

2. **Create secrets**
```bash
# Update secrets with actual values
kubectl create secret generic mongodb-secret \
  --from-literal=connection-string="mongodb://your-mongodb-host:27017/products" \
  --from-literal=username="admin" \
  --from-literal=password="SecurePassword" \
  -n ecommerce

kubectl create secret generic postgres-secret \
  --from-literal=connection-string="postgresql://your-rds-endpoint:5432/ecommerce" \
  --from-literal=username="admin" \
  --from-literal=password="SecurePassword" \
  -n ecommerce
```

3. **Deploy services**
```bash
kubectl apply -f infrastructure/kubernetes/
```

4. **Verify deployment**
```bash
kubectl get all -n ecommerce
kubectl get pods -n ecommerce -w
```

---

## Phase 4: CI/CD Pipeline Setup (Week 7-8)

### GitHub Setup

1. **Create GitHub repository**
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/your-username/ecommerce-devops.git
git push -u origin main
```

2. **Configure GitHub Secrets**

Go to Settings → Secrets and Variables → Actions, add:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `ECR_REGISTRY` (get from Terraform outputs)
- `SONAR_TOKEN` (from SonarCloud)
- `SLACK_WEBHOOK_URL` (optional)

3. **Create SonarCloud project**
- Visit https://sonarcloud.io
- Import GitHub repository
- Copy token to GitHub secrets

### Test CI/CD Pipeline

1. **Make a change**
```bash
# Edit any service file
git add .
git commit -m "Test CI/CD pipeline"
git push
```

2. **Monitor workflow**
- Go to GitHub Actions tab
- Watch pipeline execution
- Fix any failures

---

## Phase 5: Monitoring Setup (Week 9-10)

### Access Grafana

1. **Port forward to access locally**
```bash
kubectl port-forward -n monitoring \
  svc/prometheus-grafana 3000:80
```

2. **Login to Grafana**
- URL: http://localhost:3000
- Username: admin
- Password: prom-operator (default)

3. **Import dashboards**
- Kubernetes Cluster Monitoring: 15760
- Node Exporter Full: 1860
- Spring Boot Dashboard: 12900

### Configure Alertmanager

1. **Create alertmanager config**
```yaml
# Create file: alertmanager-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yml: |
    global:
      slack_api_url: 'YOUR_SLACK_WEBHOOK_URL'
    
    route:
      receiver: 'slack-notifications'
      group_by: ['alertname', 'severity']
      group_wait: 10s
      group_interval: 10m
      repeat_interval: 12h
    
    receivers:
    - name: 'slack-notifications'
      slack_configs:
      - channel: '#alerts'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
```

2. **Apply configuration**
```bash
kubectl apply -f alertmanager-config.yaml
```

---

## Phase 6: Production Hardening (Week 11-12)

### Security Checklist

- [ ] Enable Pod Security Standards
- [ ] Configure Network Policies
- [ ] Set up RBAC
- [ ] Implement secrets encryption
- [ ] Enable audit logging
- [ ] Configure backup strategy
- [ ] Set up disaster recovery

### Performance Optimization

1. **Configure HPA for all services**
2. **Set resource requests and limits**
3. **Enable cluster autoscaling**
4. **Configure Redis caching**
5. **Optimize database queries**

### Backup Configuration

```bash
# Install Velero for Kubernetes backup
velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.8.0 \
  --bucket ecommerce-k8s-backups \
  --backup-location-config region=us-east-1 \
  --snapshot-location-config region=us-east-1
```

---

## Maintenance & Operations

### Daily Tasks
- Check cluster health
- Review monitoring dashboards
- Check error logs

### Weekly Tasks
- Review resource usage
- Update dependencies
- Review security alerts

### Monthly Tasks
- Disaster recovery test
- Performance review
- Cost optimization review

---

## Troubleshooting Guide

### Pod Not Starting
```bash
kubectl describe pod <pod-name> -n ecommerce
kubectl logs <pod-name> -n ecommerce --previous
```

### Database Connection Issues
```bash
# Test connectivity from pod
kubectl run -it --rm debug --image=postgres:16-alpine --restart=Never -- \
  psql -h <rds-endpoint> -U admin -d ecommerce
```

### High Memory Usage
```bash
# Check resource usage
kubectl top pods -n ecommerce
kubectl describe node <node-name>
```

---

## Rollback Procedures

### Rollback Kubernetes Deployment
```bash
kubectl rollout undo deployment/product-service -n ecommerce
kubectl rollout status deployment/product-service -n ecommerce
```

### Rollback Terraform Changes
```bash
terraform plan -destroy
terraform apply
```

---

## Success Metrics

- ✅ All services healthy and responding
- ✅ Zero downtime during deployments
- ✅ Response time < 200ms (p95)
- ✅ Error rate < 0.1%
- ✅ Uptime > 99.9%
- ✅ Automated deployment working
- ✅ Monitoring and alerting active
