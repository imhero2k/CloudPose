# 🚀 GCP Deployment Guide for CloudPose

This guide will help you deploy your CloudPose application to Google Cloud Platform using three different approaches.

## 📋 Prerequisites

1. **Google Cloud Account**: Sign up at [cloud.google.com](https://cloud.google.com)
2. **Google Cloud SDK**: Install from [cloud.google.com/sdk](https://cloud.google.com/sdk)
3. **Docker**: Install Docker Desktop
4. **Project ID**: Create a new GCP project and note the Project ID

## 🎯 Deployment Options

### Option 1: Cloud Run (Recommended for Cost-Effective)
- **Best for**: Development, testing, cost-conscious deployments
- **Cost**: ~$5-20/month
- **Features**: Serverless, auto-scaling, pay-per-use

### Option 2: Google Kubernetes Engine (GKE)
- **Best for**: Production, high availability, complex workloads
- **Cost**: ~$50-100/month
- **Features**: Full Kubernetes, load balancing, monitoring

### Option 3: Compute Engine (VMs)
- **Best for**: Full control, custom configurations
- **Cost**: ~$30-80/month
- **Features**: Complete server control

## 🔧 Setup Steps

### Step 1: Install and Configure Google Cloud SDK

```bash
# Install gcloud CLI (if not already installed)
# Download from: https://cloud.google.com/sdk/docs/install

# Initialize gcloud
gcloud init

# Set your project
gcloud config set project YOUR_PROJECT_ID
```

### Step 2: Enable Required APIs

```bash
# Enable APIs for your chosen deployment method
gcloud services enable run.googleapis.com          # For Cloud Run
gcloud services enable container.googleapis.com    # For GKE
gcloud services enable compute.googleapis.com      # For Compute Engine
gcloud services enable containerregistry.googleapis.com  # For all
```

### Step 3: Configure Docker for GCR

```bash
# Configure Docker to use gcloud as a credential helper
gcloud auth configure-docker
```

## 🚀 Deployment Instructions

### Cloud Run Deployment (Recommended)

1. **Update the script**:
   ```bash
   # Edit deploy-cloudrun.sh and replace YOUR_PROJECT_ID
   nano deploy-cloudrun.sh
   ```

2. **Run the deployment**:
   ```bash
   chmod +x deploy-cloudrun.sh
   ./deploy-cloudrun.sh
   ```

3. **Update frontend**:
   - Copy the service URL from the output
   - Update `frontend/src/App.js` with the new API URL

### GKE Deployment

1. **Update the script**:
   ```bash
   # Edit deploy-gcp.sh and replace YOUR_PROJECT_ID
   nano deploy-gcp.sh
   ```

2. **Run the deployment**:
   ```bash
   chmod +x deploy-gcp.sh
   ./deploy-gcp.sh
   ```

3. **Access your application**:
   ```bash
   kubectl get service cloudpose-service
   ```

### Compute Engine Deployment

1. **Update the script**:
   ```bash
   # Edit deploy-compute-engine.sh and replace YOUR_PROJECT_ID
   nano deploy-compute-engine.sh
   ```

2. **Run the deployment**:
   ```bash
   chmod +x deploy-compute-engine.sh
   ./deploy-compute-engine.sh
   ```

## 🌐 Frontend Deployment

### Option A: Deploy Frontend to Cloud Run

```bash
# Build the React app
cd frontend
npm run build

# Create a simple Dockerfile for the frontend
cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# Create nginx config
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}
http {
    server {
        listen 80;
        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
            try_files $uri $uri/ /index.html;
        }
    }
}
EOF

# Deploy frontend to Cloud Run
gcloud run deploy cloudpose-frontend \
    --source . \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated
```

### Option B: Deploy to Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase
firebase init hosting

# Build and deploy
npm run build
firebase deploy
```

## 📊 Monitoring and Management

### Cloud Run
```bash
# View logs
gcloud logs tail --service=cloudpose-api

# Update service
gcloud run deploy cloudpose-api --image gcr.io/PROJECT_ID/cloudpose-backend

# Scale service
gcloud run services update cloudpose-api --max-instances 20
```

### GKE
```bash
# View pods
kubectl get pods

# View logs
kubectl logs -l app=cloudpose-backend

# Scale deployment
kubectl scale deployment cloudpose-backend --replicas=3
```

### Compute Engine
```bash
# SSH into instance
gcloud compute ssh cloudpose-vm --zone=us-central1-a

# View logs
sudo docker logs cloudpose-backend

# Restart service
sudo docker restart cloudpose-backend
```

## 💰 Cost Optimization

### Cloud Run
- Set appropriate memory limits (1-2GB for pose estimation)
- Use max instances to control costs
- Monitor usage in Cloud Console

### GKE
- Use preemptible nodes for development
- Enable cluster autoscaler
- Use appropriate machine types

### Compute Engine
- Use sustained use discounts
- Stop instances when not in use
- Use appropriate machine types

## 🔒 Security Considerations

1. **Enable HTTPS**: Use Cloud Load Balancer or Cloud Run's built-in HTTPS
2. **Set up IAM**: Use service accounts with minimal permissions
3. **Network Security**: Configure firewall rules appropriately
4. **Container Security**: Scan images for vulnerabilities

## 🆘 Troubleshooting

### Common Issues

1. **Permission Denied**:
   ```bash
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **Docker Push Fails**:
   ```bash
   gcloud auth configure-docker
   ```

3. **Service Not Accessible**:
   - Check firewall rules
   - Verify service is running
   - Check logs for errors

### Getting Help

- [Google Cloud Documentation](https://cloud.google.com/docs)
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Compute Engine Documentation](https://cloud.google.com/compute/docs)

## 📈 Next Steps

1. **Set up monitoring** with Cloud Monitoring
2. **Configure alerts** for service health
3. **Set up CI/CD** with Cloud Build
4. **Add custom domain** with Cloud DNS
5. **Implement load balancing** for high availability 