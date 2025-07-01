#!/bin/bash

# Simple CloudPose Oracle VM Deployment
echo "🚀 Deploying CloudPose to Oracle VM (Simple Method)..."

# Update system
echo "📦 Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
echo "🐳 Installing Docker..."
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Logout and login again, or run:
newgrp docker

# Pull the Docker image from Docker Hub (if you push it there)
# OR build it locally if you have the files
echo "📥 Pulling CloudPose Docker image..."

# Option 1: If you push to Docker Hub
# docker pull yourusername/cloudpose-backend:latest

# Option 2: If you have the files locally, build the image
if [ -f "docker/Dockerfile" ]; then
    echo "🔨 Building Docker image from local files..."
    docker build -t cloudpose-backend -f docker/Dockerfile .
else
    echo "❌ Dockerfile not found. Please ensure you have the Dockerfile in the docker/ directory."
    echo "   Or push your image to Docker Hub and use: docker pull yourusername/cloudpose-backend"
    exit 1
fi

# Run the container
echo "🚀 Starting CloudPose backend..."
docker run -d \
    --name cloudpose-backend \
    -p 60000:80 \
    --restart unless-stopped \
    cloudpose-backend

# Check if container is running
echo "✅ Checking container status..."
docker ps

# Get the public IP
echo "🌐 Your Oracle VM IP:"
PUBLIC_IP=$(curl -s ifconfig.me)
echo $PUBLIC_IP

echo ""
echo "🎉 Deployment complete!"
echo "🔗 Your backend is available at: http://$PUBLIC_IP:60000"
echo "📊 API Documentation: http://$PUBLIC_IP:60000/docs"
echo ""
echo "📱 Update your frontend to use this backend URL:"
echo "   http://$PUBLIC_IP:60000"
echo ""
echo "🔧 Useful commands:"
echo "   Check status: docker ps"
echo "   View logs: docker logs cloudpose-backend"
echo "   Restart: docker restart cloudpose-backend"
echo "   Stop: docker stop cloudpose-backend" 