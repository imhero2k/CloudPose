#!/bin/bash

# Minimal CloudPose Docker Deployment
echo "🚀 Running CloudPose Docker Container..."

# Install Docker (if not already installed)
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    newgrp docker
else
    echo "✅ Docker is already installed"
fi

# Stop and remove existing container (if any)
echo "🧹 Cleaning up existing containers..."
docker stop cloudpose-backend 2>/dev/null || true
docker rm cloudpose-backend 2>/dev/null || true

# Run the container
echo "🚀 Starting CloudPose backend..."
docker run -d \
    --name cloudpose-backend \
    -p 60000:80 \
    --restart unless-stopped \
    cloudpose-backend

# Check status
echo "✅ Container status:"
docker ps

# Get IP
PUBLIC_IP=$(curl -s ifconfig.me)
echo ""
echo "🎉 CloudPose is running!"
echo "🔗 Backend URL: http://$PUBLIC_IP:60000"
echo "📊 API Docs: http://$PUBLIC_IP:60000/docs"
echo ""
echo "📱 Frontend: https://imhero2k.github.io/CloudPose" 