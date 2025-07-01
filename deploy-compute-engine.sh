#!/bin/bash

# CloudPose Compute Engine Deployment Script
echo "🚀 Deploying CloudPose to Google Compute Engine..."

# Set your project ID
PROJECT_ID="your-gcp-project-id"
REGION="us-central1"
ZONE="us-central1-a"
INSTANCE_NAME="cloudpose-vm"
MACHINE_TYPE="e2-standard-2"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI not found. Please install Google Cloud SDK first."
    exit 1
fi

# Authenticate with GCP
echo "🔐 Authenticating with GCP..."
gcloud auth login

# Set project
echo "📋 Setting project to $PROJECT_ID..."
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "🔧 Enabling required APIs..."
gcloud services enable compute.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Build and push Docker image
echo "🐳 Building and pushing Docker image..."
docker build -t gcr.io/$PROJECT_ID/cloudpose-backend .
docker push gcr.io/$PROJECT_ID/cloudpose-backend

# Create startup script
cat > startup-script.sh << 'EOF'
#!/bin/bash
# Install Docker
apt-get update
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

# Pull and run the application
docker pull gcr.io/PROJECT_ID/cloudpose-backend
docker run -d \
    --name cloudpose-backend \
    -p 80:80 \
    --restart unless-stopped \
    gcr.io/PROJECT_ID/cloudpose-backend

# Install nginx for reverse proxy (optional)
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx
EOF

# Replace PROJECT_ID in startup script
sed -i "s/PROJECT_ID/$PROJECT_ID/g" startup-script.sh

# Create VM instance
echo "🏗️ Creating Compute Engine instance..."
gcloud compute instances create $INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=$MACHINE_TYPE \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --tags=http-server,https-server \
    --metadata-from-file startup-script=startup-script.sh \
    --scopes=cloud-platform

# Create firewall rule
echo "🔥 Creating firewall rule..."
gcloud compute firewall-rules create allow-http \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server

# Get external IP
echo "🌐 Getting external IP..."
EXTERNAL_IP=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="value(networkInterfaces[0].accessConfigs[0].natIP)")

echo "✅ Compute Engine deployment complete!"
echo "🔗 Your application is available at: http://$EXTERNAL_IP"
echo "📊 Check status with: gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE"
echo "🔧 SSH into instance: gcloud compute ssh $INSTANCE_NAME --zone=$ZONE" 