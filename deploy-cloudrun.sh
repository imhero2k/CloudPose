#!/bin/bash

# CloudPose Cloud Run Deployment Script
echo "🚀 Deploying CloudPose to Google Cloud Run..."

# Set your project ID
PROJECT_ID="your-gcp-project-id"
REGION="us-central1"
SERVICE_NAME="cloudpose-api"

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
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Build and push Docker image to Google Container Registry
echo "🐳 Building and pushing Docker image..."
docker build -t gcr.io/$PROJECT_ID/cloudpose-backend .
docker push gcr.io/$PROJECT_ID/cloudpose-backend

# Deploy to Cloud Run
echo "🚀 Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
    --image gcr.io/$PROJECT_ID/cloudpose-backend \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --memory 2Gi \
    --cpu 2 \
    --max-instances 10 \
    --port 80 \
    --set-env-vars "CORS_ORIGINS=http://localhost:3000,http://localhost:3001"

# Get the service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)")

echo "✅ Cloud Run deployment complete!"
echo "🔗 Your API is available at: $SERVICE_URL"
echo "📊 Check logs with: gcloud logs tail --service=$SERVICE_NAME"
echo "🔄 Update frontend API URL to: $SERVICE_URL" 