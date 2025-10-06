#!/bin/bash
# Commands to run on EC2 instance
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo systemctl enable docker

# Pull and run the backend (PUBLIC IMAGE)
sudo docker pull public.ecr.aws/a8m7d8x7/vantagepoint-backend:latest

# Stop any existing container
sudo docker stop vantagepoint-backend 2>/dev/null || true
sudo docker rm vantagepoint-backend 2>/dev/null || true

# Run the backend
sudo docker run -d \
  --name vantagepoint-backend \
  --restart always \
  -p 80:8080 \
  -e NODE_ENV=production \
  -e DATABASE_HOST=vantagepoint-production.c6ds4c4qok1n.us-east-1.rds.amazonaws.com \
  -e DATABASE_PORT=5432 \
  -e DATABASE_USERNAME=postgres \
  -e DATABASE_PASSWORD="VantagePoint2024!" \
  -e DATABASE_NAME=vantagepointcrm \
  -e JWT_SECRET="VantagePoint2024!SecretKey" \
  -e JWT_EXPIRES_IN="24h" \
  -e PORT=8080 \
  public.ecr.aws/a8m7d8x7/vantagepoint-backend:latest

# Wait for container to start
sleep 10

# Create admin user
curl -X POST http://localhost/api/v1/setup/create-admin \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"VantagePoint2024!","email":"admin@vantagepointcrm.com"}'

# Check status
sudo docker ps
sudo docker logs vantagepoint-backend
