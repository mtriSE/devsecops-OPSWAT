#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

mkdir -p /opt/coffeeshop
cd /opt/coffeeshop

cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  postgres:
    image: postgres:14-alpine
    environment:
      POSTGRES_DB: coffeeshop
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    ports: ["5432:5432"]
  
  rabbitmq:
    image: rabbitmq:3.11-management-alpine
    environment:
      RABBITMQ_DEFAULT_USER: user
      RABBITMQ_DEFAULT_PASS: pass
    ports: ["5672:5672", "15672:15672"]
  
  product:
    image: cuongopswat/go-coffeeshop-product
    environment:
      APP_NAME: "Product Service"
    ports: ["5001:5001"]
    depends_on: [postgres, rabbitmq]
  
  counter:
    image: cuongopswat/go-coffeeshop-counter
    environment:
      APP_NAME: "Counter Service"
      IN_DOCKER: "true"
      PG_URL: "postgres://user:pass@postgres:5432/coffeeshop?sslmode=disable"
      RABBITMQ_URL: "amqp://user:pass@rabbitmq:5672/"
      PRODUCT_CLIENT_URL: "product:5001"
    ports: ["5002:5002"]
    depends_on: [postgres, rabbitmq, product]
  
  barista:
    image: cuongopswat/go-coffeeshop-barista
    environment:
      APP_NAME: "Barista Service"
      IN_DOCKER: "true"
      PG_URL: "postgres://user:pass@postgres:5432/coffeeshop?sslmode=disable"
      RABBITMQ_URL: "amqp://user:pass@rabbitmq:5672/"
    depends_on: [postgres, rabbitmq]
  
  kitchen:
    image: cuongopswat/go-coffeeshop-kitchen
    environment:
      APP_NAME: "Kitchen Service"
      IN_DOCKER: "true"
      PG_URL: "postgres://user:pass@postgres:5432/coffeeshop?sslmode=disable"
      RABBITMQ_URL: "amqp://user:pass@rabbitmq:5672/"
    depends_on: [postgres, rabbitmq]
  
  proxy:
    image: cuongopswat/go-coffeeshop-proxy
    environment:
      APP_NAME: "Proxy Service"
      GRPC_PRODUCT_HOST: "product"
      GRPC_PRODUCT_PORT: "5001"
      GRPC_COUNTER_HOST: "counter"
      GRPC_COUNTER_PORT: "5002"
    ports: ["5000:5000"]
    depends_on: [product, counter]
  
  web:
    image: cuongopswat/go-coffeeshop-web
    environment:
      REVERSE_PROXY_URL: "proxy:5000"
      WEB_PORT: "8888"
    ports: ["8888:8888"]
    depends_on: [proxy]
EOF

docker-compose up -d