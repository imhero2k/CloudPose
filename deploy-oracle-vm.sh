#!/bin/bash

# CloudPose Oracle VM Deployment Script
echo "🚀 Deploying CloudPose to Oracle VM..."

# Update system
echo "📦 Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
echo "🐳 Installing Docker..."
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose (optional)
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create app directory
echo "📁 Creating application directory..."
mkdir -p ~/cloudpose
cd ~/cloudpose

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  cloudpose-backend:
    build:
      context: .
      dockerfile: docker/Dockerfile
    ports:
      - "60000:80"
    restart: unless-stopped
    environment:
      - CORS_ORIGINS=http://localhost:3000,http://localhost:3001,https://imhero2k.github.io
    volumes:
      - ./app:/app
EOF

# Clone your repository (if not already done)
if [ ! -d "CloudPose" ]; then
    echo "📥 Cloning repository..."
    git clone https://github.com/imhero2k/CloudPose.git
    cd CloudPose
else
    echo "📂 Repository already exists, updating..."
    cd CloudPose
    git pull origin master
fi

# Copy files to cloudpose directory
echo "📋 Copying files..."
cp -r app ../app/
cp -r docker ../docker/
cp -r k8s ../k8s/

cd ..

# Build and run Docker container
echo "🔨 Building Docker image..."
docker build -t cloudpose-backend -f docker/Dockerfile .

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
curl -s ifconfig.me

echo ""
echo "🎉 Deployment complete!"
echo "🔗 Your backend is available at: http://$(curl -s ifconfig.me):60000"
echo "📊 API Documentation: http://$(curl -s ifconfig.me):60000/docs"
echo ""
echo "📱 Update your frontend to use this backend URL:"
echo "   http://$(curl -s ifconfig.me):60000" 