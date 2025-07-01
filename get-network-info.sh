#!/bin/bash

# CloudPose Network Information Script
echo "🌐 CloudPose Network Information for Mobile Access"
echo "=================================================="

# Set your project ID (update this)
PROJECT_ID="your-gcp-project-id"
REGION="us-central1"

echo ""
echo "📱 Mobile Access URLs:"
echo "======================"

# Check Cloud Run service
echo "🔗 Cloud Run (if deployed):"
if gcloud run services describe cloudpose-api --region=$REGION --format="value(status.url)" 2>/dev/null; then
    CLOUD_RUN_URL=$(gcloud run services describe cloudpose-api --region=$REGION --format="value(status.url)")
    echo "   API URL: $CLOUD_RUN_URL"
    echo "   Frontend: Update frontend/src/App.js with this URL"
else
    echo "   Not deployed yet. Run: ./deploy-cloudrun.sh"
fi

echo ""

# Check GKE service
echo "🔗 GKE (if deployed):"
if kubectl get service cloudpose-service --output="value(status.loadBalancer.ingress[0].ip)" 2>/dev/null; then
    GKE_IP=$(kubectl get service cloudpose-service --output="value(status.loadBalancer.ingress[0].ip)")
    echo "   External IP: $GKE_IP"
    echo "   API: http://$GKE_IP/api/pose"
    echo "   Swagger: http://$GKE_IP/docs"
else
    echo "   Not deployed yet. Run: ./deploy-gcp.sh"
fi

echo ""

# Check Compute Engine
echo "🔗 Compute Engine (if deployed):"
if gcloud compute instances describe cloudpose-vm --zone=us-central1-a --format="value(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null; then
    VM_IP=$(gcloud compute instances describe cloudpose-vm --zone=us-central1-a --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
    echo "   External IP: $VM_IP"
    echo "   API: http://$VM_IP/api/pose"
    echo "   Swagger: http://$VM_IP/docs"
else
    echo "   Not deployed yet. Run: ./deploy-compute-engine.sh"
fi

echo ""
echo "📋 Mobile Testing Instructions:"
echo "==============================="
echo "1. Make sure your mobile is on the same WiFi network as your computer"
echo "2. Use the IP addresses/URLs above in your mobile browser"
echo "3. For API testing, use: http://[IP]/docs (Swagger UI)"
echo "4. For frontend, deploy frontend to a public URL (see GCP_DEPLOYMENT_GUIDE.md)"

echo ""
echo "🔧 Quick Test Commands:"
echo "======================"
echo "# Test API from mobile (replace with actual IP/URL):"
echo "curl -X POST http://[IP]/api/pose \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"image\":\"base64_encoded_image\",\"file_name\":\"test.jpg\"}'" 