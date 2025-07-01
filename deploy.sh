#!/bin/bash

# CloudPose Deployment Script
# FIT5225 Assignment 1

set -e

echo "🚀 Starting CloudPose deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

print_status "Building Docker image..."
docker build -f docker/Dockerfile -t cloudpose:latest .

if [ $? -eq 0 ]; then
    print_status "Docker image built successfully!"
else
    print_error "Failed to build Docker image"
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_warning "kubectl not found. Skipping Kubernetes deployment."
    print_status "You can manually deploy using:"
    echo "  kubectl apply -f k8s/deployment.yaml"
    echo "  kubectl apply -f k8s/service.yaml"
    exit 0
fi

print_status "Deploying to Kubernetes..."

# Create namespace if it doesn't exist
kubectl create namespace assignment1 --dry-run=client -o yaml | kubectl apply -f -

# Apply deployment
print_status "Applying deployment..."
kubectl apply -f k8s/deployment.yaml

# Apply service
print_status "Applying service..."
kubectl apply -f k8s/service.yaml

# Wait for deployment to be ready
print_status "Waiting for deployment to be ready..."
kubectl rollout status deployment/pose-estimator -n assignment1 --timeout=300s

# Get service information
print_status "Getting service information..."
kubectl get services -n assignment1

print_status "Deployment completed successfully!"
print_status "Service endpoints:"
echo "  - JSON API: http://[NODE_IP]:30080/api/pose"
echo "  - Image API: http://[NODE_IP]:30080/api/pose/annotated"

print_status "To check pod status: kubectl get pods -n assignment1"
print_status "To view logs: kubectl logs -f deployment/pose-estimator -n assignment1"
print_status "To scale pods: kubectl scale deployment pose-estimator --replicas=4 -n assignment1" 