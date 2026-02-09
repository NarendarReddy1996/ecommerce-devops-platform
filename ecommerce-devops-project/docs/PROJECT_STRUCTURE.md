# Project Structure

```
ecommerce-devops-project/
│
├── README.md                          # Main project documentation
├── docker-compose.yml                 # Local development environment
│
├── services/                          # Microservices
│   ├── product-service/               # Product catalog service (Node.js)
│   │   ├── server.js                  # Main application
│   │   ├── package.json               # Dependencies
│   │   └── Dockerfile                 # Container image
│   │
│   ├── user-service/                  # User management service (Java/Spring Boot)
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── java/              # Java source code
│   │   │       └── resources/         # Configuration files
│   │   ├── pom.xml                    # Maven dependencies
│   │   └── Dockerfile                 # Container image
│   │
│   ├── order-service/                 # Order processing service (Node.js)
│   │   ├── server.js                  # Main application
│   │   ├── package.json               # Dependencies
│   │   └── Dockerfile                 # Container image
│   │
│   └── payment-service/               # Payment processing service (Python/FastAPI)
│       ├── main.py                    # Main application
│       ├── requirements.txt           # Dependencies
│       └── Dockerfile                 # Container image
│
├── frontend/                          # React frontend
│   ├── src/
│   │   ├── App.js                     # Main React component
│   │   └── App.css                    # Styles
│   ├── package.json                   # Dependencies
│   ├── Dockerfile                     # Container image
│   └── nginx.conf                     # Nginx configuration
│
├── infrastructure/                    # Infrastructure as Code
│   ├── terraform/                     # Terraform configurations
│   │   ├── main.tf                    # Main infrastructure definition
│   │   ├── variables.tf               # Input variables
│   │   ├── outputs.tf                 # Output values
│   │   └── modules/                   # Reusable modules
│   │       ├── vpc/                   # VPC module
│   │       ├── eks/                   # EKS cluster module
│   │       ├── rds/                   # RDS database module
│   │       └── elasticache/           # Redis cache module
│   │
│   ├── kubernetes/                    # Kubernetes manifests
│   │   ├── namespace.yaml             # Namespace definition
│   │   ├── configmaps-secrets.yaml    # Configuration and secrets
│   │   ├── product-service.yaml       # Product service deployment
│   │   ├── user-service.yaml          # User service deployment
│   │   ├── order-service.yaml         # Order service deployment
│   │   ├── payment-service.yaml       # Payment service deployment
│   │   ├── frontend.yaml              # Frontend deployment
│   │   └── ingress.yaml               # Ingress configuration
│   │
│   └── ansible/                       # Ansible playbooks (optional)
│       ├── inventory/                 # Server inventory
│       └── playbooks/                 # Configuration playbooks
│
├── ci-cd/                             # CI/CD configurations
│   ├── jenkins/                       # Jenkins pipeline
│   │   └── Jenkinsfile                # Pipeline definition
│   │
│   └── github-actions/                # GitHub Actions (in use)
│       └── workflows/
│           └── ci-cd.yml              # Main CI/CD workflow
│
├── monitoring/                        # Monitoring configurations
│   ├── prometheus/                    # Prometheus setup
│   │   ├── prometheus.yml             # Scrape configuration
│   │   └── rules/
│   │       └── alerts.yml             # Alerting rules
│   │
│   └── grafana/                       # Grafana setup
│       ├── dashboards/                # Dashboard definitions
│       └── datasources/               # Data source configurations
│
├── scripts/                           # Utility scripts
│   ├── setup.sh                       # Local environment setup
│   ├── deploy.sh                      # Deployment script
│   ├── backup.sh                      # Backup script
│   └── init-postgres.sql              # Database initialization
│
├── docs/                              # Documentation
│   ├── DEPLOYMENT_GUIDE.md            # Deployment instructions
│   ├── INTERVIEW_GUIDE.md             # Interview preparation
│   ├── ARCHITECTURE.md                # Architecture documentation
│   └── TROUBLESHOOTING.md             # Common issues and solutions
│
└── .github/                           # GitHub configurations
    └── workflows/
        └── ci-cd.yml                  # CI/CD pipeline (actual file)
```

## Key Components

### Microservices
All services follow these principles:
- **Health checks** at `/health` endpoint
- **Metrics** exposed at `/metrics` for Prometheus
- **Structured logging** in JSON format
- **Graceful shutdown** handling
- **Environment-based configuration**

### Databases
- **MongoDB**: Product catalog (flexible schema)
- **PostgreSQL**: Users and orders (ACID transactions)
- **Redis**: Caching and sessions (performance)

### Infrastructure
- **Terraform**: Provisions cloud resources (VPC, EKS, RDS, etc.)
- **Kubernetes**: Orchestrates containerized services
- **Helm**: Package manager for Kubernetes (optional)

### CI/CD
- **GitHub Actions**: Automated testing, building, and deployment
- **Multi-stage pipeline**: Quality → Test → Build → Deploy
- **Environment separation**: Dev, Staging, Production

### Monitoring Stack
- **Prometheus**: Metrics collection and storage
- **Grafana**: Metrics visualization
- **Alertmanager**: Alert routing and notification
- **ELK Stack**: Log aggregation and analysis

## File Purposes

### Configuration Files
- `docker-compose.yml`: Local development environment
- `prometheus.yml`: Metrics collection configuration
- `ingress.yaml`: Traffic routing and SSL termination
- `terraform.tfvars`: Environment-specific variables

### Application Files
- `server.js` / `main.py`: Service entry points
- `Dockerfile`: Container image definitions
- `package.json` / `pom.xml` / `requirements.txt`: Dependencies

### Infrastructure Files
- `*.tf`: Terraform infrastructure definitions
- `*.yaml`: Kubernetes resource definitions
- `Jenkinsfile` / `ci-cd.yml`: Pipeline definitions

### Documentation
- `README.md`: Project overview
- `DEPLOYMENT_GUIDE.md`: Step-by-step deployment
- `INTERVIEW_GUIDE.md`: Interview preparation
- `*.md`: Various documentation files

## Getting Started

1. **Local Development**
   ```bash
   ./scripts/setup.sh
   ```

2. **Cloud Deployment**
   ```bash
   cd infrastructure/terraform
   terraform init
   terraform apply
   ```

3. **Kubernetes Deployment**
   ```bash
   kubectl apply -f infrastructure/kubernetes/
   ```

## Environment Variables

Each service requires these environment variables:

### Product Service
- `PORT`: Service port (default: 3001)
- `MONGO_URI`: MongoDB connection string
- `NODE_ENV`: Environment (development/production)

### User Service
- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET`: Secret for token signing
- `SERVER_PORT`: Service port (default: 3002)

### Order Service
- `PORT`: Service port (default: 3003)
- `DB_HOST`: PostgreSQL host
- `REDIS_URL`: Redis connection string

### Payment Service
- `PORT`: Service port (default: 3004)
- `PAYMENT_GATEWAY_API_KEY`: Payment provider API key

## Next Steps

1. Review the [Deployment Guide](docs/DEPLOYMENT_GUIDE.md)
2. Study the [Interview Guide](docs/INTERVIEW_GUIDE.md)
3. Set up your local environment
4. Deploy to cloud (AWS/Azure/GCP)
5. Implement monitoring and alerting
6. Practice troubleshooting scenarios

## Additional Resources

- Kubernetes: https://kubernetes.io/docs/
- Terraform: https://www.terraform.io/docs/
- Prometheus: https://prometheus.io/docs/
- Docker: https://docs.docker.com/
