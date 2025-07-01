#!/bin/bash

# CloudPose GCP Deployment Script
echo "🚀 Deploying CloudPose to Google Cloud Platform..."

# Set your project ID
PROJECT_ID="your-gcp-project-id"
REGION="us-central1"
CLUSTER_NAME="cloudpose-cluster"

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
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com

# Create GKE cluster (if it doesn't exist)
echo "🏗️ Creating GKE cluster..."
gcloud container clusters create $CLUSTER_NAME \
    --region=$REGION \
    --num-nodes=2 \
    --machine-type=e2-standard-2 \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=5

# Get credentials
echo "🔑 Getting cluster credentials..."
gcloud container clusters get-credentials $CLUSTER_NAME --region=$REGION

# Build and push Docker image to Google Container Registry
echo "🐳 Building and pushing Docker image..."
docker build -t gcr.io/$PROJECT_ID/cloudpose-backend .
docker push gcr.io/$PROJECT_ID/cloudpose-backend

# Update deployment with correct image
echo "📝 Updating deployment with GCR image..."
sed -i "s|image: cloudpose-backend|image: gcr.io/$PROJECT_ID/cloudpose-backend|g" k8s/deployment.yaml

# Deploy to Kubernetes
echo "🚀 Deploying to Kubernetes..."
kubectl apply -f k8s/

# Wait for deployment
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/cloudpose-backend

# Get external IP
echo "🌐 Getting external IP..."
kubectl get service cloudpose-service

echo "✅ Deployment complete!"
echo "🔗 Your application should be available at the external IP above"
echo "📊 Check status with: kubectl get pods"
echo "📋 View logs with: kubectl logs -l app=cloudpose-backend" 