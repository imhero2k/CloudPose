# CloudPose Deployment Script for Windows
# FIT5225 Assignment 1

param(
    [switch]$SkipDocker,
    [switch]$SkipK8s
)

Write-Host "🚀 Starting CloudPose deployment..." -ForegroundColor Green

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check if Docker is running
if (-not $SkipDocker) {
    try {
        docker info | Out-Null
    }
    catch {
        Write-Error "Docker is not running. Please start Docker Desktop and try again."
        exit 1
    }

    Write-Status "Building Docker image..."
    try {
        docker build -f docker/Dockerfile -t cloudpose:latest .
        Write-Status "Docker image built successfully!"
    }
    catch {
        Write-Error "Failed to build Docker image"
        exit 1
    }
}
else {
    Write-Warning "Skipping Docker build as requested"
}

# Check if kubectl is available
if (-not $SkipK8s) {
    try {
        kubectl version --client | Out-Null
    }
    catch {
        Write-Warning "kubectl not found. Skipping Kubernetes deployment."
        Write-Status "You can manually deploy using:"
        Write-Host "  kubectl apply -f k8s/deployment.yaml"
        Write-Host "  kubectl apply -f k8s/service.yaml"
        exit 0
    }

    Write-Status "Deploying to Kubernetes..."

    # Create namespace if it doesn't exist
    Write-Status "Creating namespace..."
    kubectl create namespace assignment1 --dry-run=client -o yaml | kubectl apply -f -

    # Apply deployment
    Write-Status "Applying deployment..."
    kubectl apply -f k8s/deployment.yaml

    # Apply service
    Write-Status "Applying service..."
    kubectl apply -f k8s/service.yaml

    # Wait for deployment to be ready
    Write-Status "Waiting for deployment to be ready..."
    kubectl rollout status deployment/pose-estimator -n assignment1 --timeout=300s

    # Get service information
    Write-Status "Getting service information..."
    kubectl get services -n assignment1

    Write-Status "Deployment completed successfully!"
    Write-Status "Service endpoints:"
    Write-Host "  - JSON API: http://[NODE_IP]:30080/api/pose"
    Write-Host "  - Image API: http://[NODE_IP]:30080/api/pose/annotated"

    Write-Status "Useful commands:"
    Write-Host "  - Check pod status: kubectl get pods -n assignment1"
    Write-Host "  - View logs: kubectl logs -f deployment/pose-estimator -n assignment1"
    Write-Host "  - Scale pods: kubectl scale deployment pose-estimator --replicas=4 -n assignment1"
}
else {
    Write-Warning "Skipping Kubernetes deployment as requested"
}

Write-Status "Deployment script completed!" 