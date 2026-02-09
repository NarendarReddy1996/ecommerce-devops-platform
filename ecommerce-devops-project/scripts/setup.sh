#!/bin/bash

set -e

echo "🚀 E-Commerce DevOps Project - Local Setup"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
check_prerequisites() {
    echo -e "\n${YELLOW}Checking prerequisites...${NC}"
    
    commands=("docker" "docker-compose" "curl")
    missing=()
    
    for cmd in "${commands[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            missing+=($cmd)
            echo -e "${RED}✗${NC} $cmd is not installed"
        else
            echo -e "${GREEN}✓${NC} $cmd is installed"
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "\n${RED}Error: Missing required tools: ${missing[*]}${NC}"
        echo "Please install them and try again."
        exit 1
    fi
}

# Create necessary directories
create_directories() {
    echo -e "\n${YELLOW}Creating necessary directories...${NC}"
    mkdir -p scripts logs data/{mongodb,postgres,redis}
    echo -e "${GREEN}✓${NC} Directories created"
}

# Create initialization SQL script
create_init_sql() {
    echo -e "\n${YELLOW}Creating database initialization script...${NC}"
    
    cat > scripts/init-postgres.sql <<EOF
-- Create databases
CREATE DATABASE IF NOT EXISTS users;
CREATE DATABASE IF NOT EXISTS orders;

-- Create users table
\\c users;
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    role VARCHAR(50) DEFAULT 'CUSTOMER',
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create orders table
\\c orders;
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    shipping_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOF
    
    echo -e "${GREEN}✓${NC} Database initialization script created"
}

# Start services
start_services() {
    echo -e "\n${YELLOW}Starting Docker containers...${NC}"
    docker-compose up -d
    
    echo -e "\n${YELLOW}Waiting for services to be healthy...${NC}"
    sleep 10
}

# Health check
health_check() {
    echo -e "\n${YELLOW}Running health checks...${NC}"
    
    services=(
        "Product Service:http://localhost:3001/health"
        "Order Service:http://localhost:3003/health"
        "Payment Service:http://localhost:3004/health"
    )
    
    all_healthy=true
    
    for service in "${services[@]}"; do
        name="${service%%:*}"
        url="${service#*:}"
        
        if curl -f -s "$url" > /dev/null; then
            echo -e "${GREEN}✓${NC} $name is healthy"
        else
            echo -e "${RED}✗${NC} $name is not responding"
            all_healthy=false
        fi
    done
    
    # User Service (Spring Boot)
    if curl -f -s "http://localhost:3002/actuator/health" > /dev/null; then
        echo -e "${GREEN}✓${NC} User Service is healthy"
    else
        echo -e "${RED}✗${NC} User Service is not responding"
        all_healthy=false
    fi
    
    if [ "$all_healthy" = false ]; then
        echo -e "\n${YELLOW}Some services are not healthy. Check logs with:${NC}"
        echo "docker-compose logs <service-name>"
    fi
}

# Seed sample data
seed_data() {
    echo -e "\n${YELLOW}Seeding sample data...${NC}"
    
    # Wait a bit more for services to fully initialize
    sleep 5
    
    products=(
        '{"name":"Laptop","description":"High-performance laptop","price":999.99,"category":"Electronics","stock":50}'
        '{"name":"Smartphone","description":"Latest smartphone","price":699.99,"category":"Electronics","stock":100}'
        '{"name":"Headphones","description":"Wireless headphones","price":149.99,"category":"Audio","stock":75}'
        '{"name":"Smartwatch","description":"Fitness smartwatch","price":249.99,"category":"Wearables","stock":60}'
        '{"name":"Tablet","description":"10-inch tablet","price":399.99,"category":"Electronics","stock":40}'
    )
    
    for product in "${products[@]}"; do
        response=$(curl -s -X POST http://localhost:3001/api/products \
            -H "Content-Type: application/json" \
            -d "$product")
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓${NC} Added product: $(echo $product | grep -o '"name":"[^"]*"' | cut -d'"' -f4)"
        else
            echo -e "${RED}✗${NC} Failed to add product"
        fi
    done
}

# Display access information
display_info() {
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}Setup Complete! 🎉${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    echo -e "\n${YELLOW}Application URLs:${NC}"
    echo "Frontend:          http://localhost"
    echo "Product Service:   http://localhost:3001"
    echo "User Service:      http://localhost:3002"
    echo "Order Service:     http://localhost:3003"
    echo "Payment Service:   http://localhost:3004"
    
    echo -e "\n${YELLOW}Monitoring:${NC}"
    echo "Prometheus:        http://localhost:9090"
    echo "Grafana:           http://localhost:3000 (admin/admin)"
    
    echo -e "\n${YELLOW}Databases:${NC}"
    echo "MongoDB:           mongodb://localhost:27017"
    echo "PostgreSQL:        postgresql://localhost:5432"
    echo "Redis:             redis://localhost:6379"
    
    echo -e "\n${YELLOW}Useful Commands:${NC}"
    echo "Stop all:          docker-compose down"
    echo "View logs:         docker-compose logs -f [service-name]"
    echo "Restart service:   docker-compose restart [service-name]"
    echo "View containers:   docker-compose ps"
    
    echo -e "\n${YELLOW}Next Steps:${NC}"
    echo "1. Open http://localhost in your browser"
    echo "2. Try creating an order"
    echo "3. Check Grafana dashboards"
    echo "4. Review logs for any errors"
    
    echo ""
}

# Main execution
main() {
    check_prerequisites
    create_directories
    create_init_sql
    start_services
    health_check
    seed_data
    display_info
}

main
