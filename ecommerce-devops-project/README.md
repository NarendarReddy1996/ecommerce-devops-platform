# E-Commerce DevOps Platform

A complete, production-ready e-commerce platform built with microservices architecture, demonstrating enterprise-level DevOps practices.

## 🏗️ Architecture Overview

### Microservices
- **Product Service** (Node.js) - Product catalog and inventory management
- **User Service** (Java Spring Boot) - User authentication and profiles
- **Order Service** (Node.js) - Order processing and management
- **Payment Service** (Python FastAPI) - Payment processing
- **Frontend** (React) - Customer-facing web application

### Technology Stack

#### Backend
- Node.js with Express
- Java Spring Boot
- Python FastAPI
- MongoDB (Product data)
- PostgreSQL (User & Order data)
- Redis (Caching)

#### DevOps Tools
- **Containerization**: Docker
- **Orchestration**: Kubernetes (EKS/GKE/AKS)
- **IaC**: Terraform, Ansible
- **CI/CD**: GitHub Actions, Jenkins
- **Monitoring**: Prometheus, Grafana
- **Logging**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **Service Mesh**: Istio (optional)
- **Security**: Trivy, SonarQube, Vault

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- kubectl
- Terraform
- AWS CLI (or equivalent for your cloud provider)
- Node.js 18+
- Java 17+
- Python 3.11+

### Local Development Setup

1. **Clone the repository**
```bash
git clone https://github.com/your-org/ecommerce-devops-project.git
cd ecommerce-devops-project
```

2. **Start services with Docker Compose**
```bash
docker-compose up -d
```

3. **Access the application**
- Frontend: http://localhost:80
- Product Service: http://localhost:3001
- User Service: http://localhost:3002
- Order Service: http://localhost:3003
- Payment Service: http://localhost:3004
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin)

4. **Seed sample data**
```bash
# Seed products
curl -X POST http://localhost:3001/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop",
    "description": "High-performance laptop",
    "price": 999.99,
    "category": "Electronics",
    "stock": 50,
    "imageUrl": "https://example.com/laptop.jpg"
  }'
```

## 🏭 Production Deployment

### Infrastructure Provisioning with Terraform

1. **Initialize Terraform**
```bash
cd infrastructure/terraform
terraform init
```

2. **Create tfvars file**
```bash
cat > terraform.tfvars <<EOF
aws_region = "us-east-1"
environment = "prod"
project_name = "ecommerce"
db_username = "admin"
db_password = "your-secure-password"
EOF
```

3. **Plan and apply**
```bash
terraform plan
terraform apply
```

### Kubernetes Deployment

1. **Configure kubectl**
```bash
aws eks update-kubeconfig --name ecommerce-prod --region us-east-1
```

2. **Create namespace and secrets**
```bash
kubectl apply -f infrastructure/kubernetes/namespace.yaml
kubectl apply -f infrastructure/kubernetes/configmaps-secrets.yaml
```

3. **Deploy services**
```bash
kubectl apply -f infrastructure/kubernetes/
```

4. **Verify deployment**
```bash
kubectl get pods -n ecommerce
kubectl get services -n ecommerce
```

## 📊 Monitoring & Observability

### Prometheus Metrics
Each service exposes metrics at `/metrics` endpoint:
- HTTP request duration
- Request count by status code
- Custom business metrics (orders, payments, etc.)

### Grafana Dashboards
Pre-configured dashboards available:
- Cluster Overview
- Service Health
- Business Metrics
- Resource Usage

### Alerting
Alerts configured for:
- High CPU/Memory usage
- Service downtime
- High error rates
- Slow response times
- Payment failures

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

**Stages:**
1. **Code Quality** - SonarQube analysis
2. **Security Scan** - Trivy vulnerability scanning
3. **Test** - Unit and integration tests
4. **Build** - Docker image creation
5. **Push** - ECR/Docker Hub
6. **Deploy** - Kubernetes deployment
7. **Smoke Test** - Post-deployment validation

### Deployment Strategies

**Development**: Automatic deployment on push to `develop` branch

**Production**: Manual approval required for `main` branch
- Blue-Green deployment
- Canary releases available
- Automatic rollback on failure

## 🔐 Security Features

- Container image scanning with Trivy
- SAST with SonarQube
- Secrets management with AWS Secrets Manager/Vault
- Network policies in Kubernetes
- RBAC for access control
- SSL/TLS with cert-manager
- Security headers in Nginx

## 📈 Scaling

### Horizontal Pod Autoscaling
```yaml
Metrics:
- CPU utilization: 70%
- Memory utilization: 80%
- Custom metrics: requests per second

Min replicas: 2
Max replicas: 10
```

### Cluster Autoscaling
- Node groups with spot instances
- Automatic scaling based on pending pods
- Cost optimization with right-sizing

## 🧪 Testing

### Run Tests Locally

**Product Service (Node.js)**
```bash
cd services/product-service
npm install
npm test
```

**User Service (Java)**
```bash
cd services/user-service
mvn test
```

**Load Testing**
```bash
# Using k6
k6 run tests/load/product-service-load.js
```

## 📝 API Documentation

### Product Service
- `GET /api/products` - List all products
- `GET /api/products/:id` - Get product by ID
- `POST /api/products` - Create product
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product

### Order Service
- `GET /api/orders` - List orders
- `GET /api/orders/:id` - Get order details
- `POST /api/orders` - Create order
- `PATCH /api/orders/:id/status` - Update order status

### Payment Service
- `POST /api/payments` - Process payment
- `GET /api/payments/:id` - Get payment details
- `POST /api/payments/:id/refund` - Refund payment

## 🛠️ Troubleshooting

### View logs
```bash
# Service logs
kubectl logs -f deployment/product-service -n ecommerce

# All pods in namespace
kubectl logs -l app=product-service -n ecommerce --all-containers=true
```

### Debug pod issues
```bash
kubectl describe pod <pod-name> -n ecommerce
kubectl get events -n ecommerce --sort-by='.lastTimestamp'
```

### Access pod shell
```bash
kubectl exec -it <pod-name> -n ecommerce -- /bin/sh
```

## 🎯 Interview Preparation Topics

This project covers:
- ✅ Microservices architecture
- ✅ Containerization & orchestration
- ✅ Infrastructure as Code
- ✅ CI/CD pipelines
- ✅ Monitoring & logging
- ✅ Security best practices
- ✅ High availability & disaster recovery
- ✅ Performance optimization
- ✅ Cloud platforms (AWS/Azure/GCP)
- ✅ Git workflows

## 📚 Learning Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Terraform Guides](https://learn.hashicorp.com/terraform)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [AWS EKS Workshop](https://www.eksworkshop.com/)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Authors

DevOps Team - E-commerce Platform

## 🙏 Acknowledgments

Built for DevOps interview preparation and hands-on learning.
