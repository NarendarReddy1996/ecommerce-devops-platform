# Quick Start Guide - 30 Minutes to Running Application

This guide will get the e-commerce platform running locally in under 30 minutes.

## Prerequisites (5 minutes)

### Install Required Tools

**macOS:**
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install docker docker-compose git
```

**Ubuntu/Debian:**
```bash
# Update package list
sudo apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt-get install docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

**Windows:**
- Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop)
- Docker Compose is included with Docker Desktop

### Verify Installation
```bash
docker --version
docker-compose --version
git --version
```

---

## Step 1: Get the Code (2 minutes)

```bash
# Clone repository
git clone <your-repository-url>
cd ecommerce-devops-project

# Or if starting from scratch, copy the project files to a new directory
```

---

## Step 2: Start All Services (5 minutes)

### Option A: Using the Setup Script (Recommended)
```bash
# Make script executable
chmod +x scripts/setup.sh

# Run setup script
./scripts/setup.sh
```

The script will:
- ✅ Check prerequisites
- ✅ Create necessary directories
- ✅ Start all Docker containers
- ✅ Run health checks
- ✅ Seed sample data
- ✅ Display access URLs

### Option B: Manual Setup
```bash
# Start all services
docker-compose up -d

# Wait for services to be healthy (60 seconds)
sleep 60

# Check service status
docker-compose ps
```

---

## Step 3: Verify Services (3 minutes)

### Check Service Health

```bash
# Product Service
curl http://localhost:3001/health

# User Service
curl http://localhost:3002/actuator/health

# Order Service
curl http://localhost:3003/health

# Payment Service
curl http://localhost:3004/health
```

All should return `{"status":"healthy"...}` or similar.

### View Logs
```bash
# View all logs
docker-compose logs

# Follow logs for a specific service
docker-compose logs -f product-service
```

---

## Step 4: Add Sample Data (3 minutes)

### Create Sample Products

```bash
# Product 1: Laptop
curl -X POST http://localhost:3001/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Gaming Laptop",
    "description": "High-performance gaming laptop with RTX 4080",
    "price": 1899.99,
    "category": "Electronics",
    "stock": 25,
    "imageUrl": "https://via.placeholder.com/300x200?text=Laptop"
  }'

# Product 2: Smartphone
curl -X POST http://localhost:3001/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Smartphone Pro",
    "description": "Latest flagship smartphone",
    "price": 999.99,
    "category": "Electronics",
    "stock": 50,
    "imageUrl": "https://via.placeholder.com/300x200?text=Phone"
  }'

# Product 3: Headphones
curl -X POST http://localhost:3001/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Wireless Headphones",
    "description": "Noise-cancelling wireless headphones",
    "price": 299.99,
    "category": "Audio",
    "stock": 100,
    "imageUrl": "https://via.placeholder.com/300x200?text=Headphones"
  }'
```

### Verify Products
```bash
curl http://localhost:3001/api/products | jq
```

---

## Step 5: Access the Application (2 minutes)

### Open in Browser

**Frontend Application:**
- URL: http://localhost
- Should display product catalog with 3 products

**Monitoring Dashboards:**
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000
  - Username: `admin`
  - Password: `admin`

### Test the Application Flow

1. **Browse Products**: See the catalog on the homepage
2. **Add to Cart**: Click "Add to Cart" on any product
3. **View Cart**: See items in the cart sidebar
4. **Place Order**: Click "Checkout" (will create an order)
5. **Check Metrics**: Visit Prometheus to see metrics

---

## Step 6: Explore Monitoring (5 minutes)

### Prometheus

1. Open http://localhost:9090
2. Try these queries:
   ```
   # Request rate per service
   rate(http_requests_total[1m])
   
   # Memory usage
   container_memory_usage_bytes
   
   # Active orders
   orders_total
   ```

### Grafana

1. Open http://localhost:3000
2. Login with `admin` / `admin`
3. Click "Dashboards" → "Browse"
4. Import a dashboard:
   - Click "New" → "Import"
   - Enter Dashboard ID: `1860` (Node Exporter Full)
   - Click "Load" → "Import"

---

## Step 7: Make Your First Code Change (5 minutes)

### Modify Product Service

1. **Edit the product service**
```bash
# Open the file
nano services/product-service/server.js

# Or use your preferred editor
code services/product-service/server.js
```

2. **Find the health check endpoint** (around line 35)
```javascript
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'product-service', 
    timestamp: new Date() 
  });
});
```

3. **Add a version field**
```javascript
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'product-service',
    version: '1.0.1',  // Added this line
    timestamp: new Date() 
  });
});
```

4. **Rebuild and restart the service**
```bash
# Rebuild the container
docker-compose build product-service

# Restart the service
docker-compose restart product-service

# Test the change
curl http://localhost:3001/health
```

You should see the new `version` field in the response!

---

## Common Commands Reference

### Docker Compose

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f [service-name]

# Restart a service
docker-compose restart [service-name]

# Rebuild a service
docker-compose build [service-name]

# View running containers
docker-compose ps

# Remove all containers and volumes
docker-compose down -v
```

### Testing APIs

```bash
# List all products
curl http://localhost:3001/api/products

# Get single product (replace {id} with actual ID)
curl http://localhost:3001/api/products/{id}

# Create an order
curl -X POST http://localhost:3003/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "items": [{
      "productId": 1,
      "quantity": 2,
      "price": 999.99
    }],
    "shippingAddress": "123 Main St, City, Country"
  }'
```

---

## Troubleshooting

### Services Won't Start

**Issue**: Port already in use
```bash
# Find what's using the port
lsof -i :3001  # or :3002, :3003, etc.

# Kill the process
kill -9 <PID>
```

**Issue**: Docker daemon not running
```bash
# Start Docker
sudo systemctl start docker  # Linux
# or open Docker Desktop on macOS/Windows
```

### Can't Connect to Database

```bash
# Check if databases are running
docker-compose ps

# View database logs
docker-compose logs mongodb
docker-compose logs postgres

# Restart databases
docker-compose restart mongodb postgres
```

### Containers Keep Restarting

```bash
# Check logs for errors
docker-compose logs [service-name]

# Check container status
docker inspect [container-name]
```

---

## Next Steps

Now that you have the application running:

1. **Explore the Code**
   - Review service implementations
   - Understand API endpoints
   - Check Docker configurations

2. **Read Documentation**
   - [Deployment Guide](DEPLOYMENT_GUIDE.md) - Production deployment
   - [Interview Guide](INTERVIEW_GUIDE.md) - Interview preparation
   - [Project Structure](PROJECT_STRUCTURE.md) - Code organization

3. **Practice DevOps Tasks**
   - Modify service code
   - Add new features
   - Create new endpoints
   - Write tests
   - Update Docker images

4. **Learn Kubernetes**
   - Install minikube
   - Deploy to local Kubernetes
   - Practice kubectl commands

5. **Set Up CI/CD**
   - Configure GitHub Actions
   - Set up automated testing
   - Practice deployment strategies

---

## Quick Reference Card

| Component | URL | Port |
|-----------|-----|------|
| Frontend | http://localhost | 80 |
| Product Service | http://localhost:3001 | 3001 |
| User Service | http://localhost:3002 | 3002 |
| Order Service | http://localhost:3003 | 3003 |
| Payment Service | http://localhost:3004 | 3004 |
| Prometheus | http://localhost:9090 | 9090 |
| Grafana | http://localhost:3000 | 3000 |
| MongoDB | mongodb://localhost | 27017 |
| PostgreSQL | postgresql://localhost | 5432 |
| Redis | redis://localhost | 6379 |

**Default Credentials:**
- Grafana: admin / admin
- PostgreSQL: postgres / postgres
- MongoDB: No authentication (local only)

---

## Getting Help

- Check logs: `docker-compose logs -f`
- Review documentation in `/docs`
- Check GitHub issues
- Review service health checks

**Congratulations!** 🎉 You now have a fully functional e-commerce platform running locally!
