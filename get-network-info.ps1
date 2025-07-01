# CloudPose Network Information Script for Windows
Write-Host "🌐 CloudPose Network Information for Mobile Access" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# Set your project ID (update this)
$PROJECT_ID = "your-gcp-project-id"
$REGION = "us-central1"

Write-Host ""
Write-Host "📱 Mobile Access URLs:" -ForegroundColor Yellow
Write-Host "======================" -ForegroundColor Yellow

# Check Cloud Run service
Write-Host "🔗 Cloud Run (if deployed):" -ForegroundColor Cyan
try {
    $CLOUD_RUN_URL = gcloud run services describe cloudpose-api --region=$REGION --format="value(status.url)" 2>$null
    if ($CLOUD_RUN_URL) {
        Write-Host "   API URL: $CLOUD_RUN_URL" -ForegroundColor White
        Write-Host "   Frontend: Update frontend/src/App.js with this URL" -ForegroundColor Gray
    } else {
        Write-Host "   Not deployed yet. Run: ./deploy-cloudrun.sh" -ForegroundColor Red
    }
} catch {
    Write-Host "   Not deployed yet. Run: ./deploy-cloudrun.sh" -ForegroundColor Red
}

Write-Host ""

# Check GKE service
Write-Host "🔗 GKE (if deployed):" -ForegroundColor Cyan
try {
    $GKE_IP = kubectl get service cloudpose-service --output="value(status.loadBalancer.ingress[0].ip)" 2>$null
    if ($GKE_IP) {
        Write-Host "   External IP: $GKE_IP" -ForegroundColor White
        Write-Host "   API: http://$GKE_IP/api/pose" -ForegroundColor White
        Write-Host "   Swagger: http://$GKE_IP/docs" -ForegroundColor White
    } else {
        Write-Host "   Not deployed yet. Run: ./deploy-gcp.sh" -ForegroundColor Red
    }
} catch {
    Write-Host "   Not deployed yet. Run: ./deploy-gcp.sh" -ForegroundColor Red
}

Write-Host ""

# Check Compute Engine
Write-Host "🔗 Compute Engine (if deployed):" -ForegroundColor Cyan
try {
    $VM_IP = gcloud compute instances describe cloudpose-vm --zone=us-central1-a --format="value(networkInterfaces[0].accessConfigs[0].natIP)" 2>$null
    if ($VM_IP) {
        Write-Host "   External IP: $VM_IP" -ForegroundColor White
        Write-Host "   API: http://$VM_IP/api/pose" -ForegroundColor White
        Write-Host "   Swagger: http://$VM_IP/docs" -ForegroundColor White
    } else {
        Write-Host "   Not deployed yet. Run: ./deploy-compute-engine.sh" -ForegroundColor Red
    }
} catch {
    Write-Host "   Not deployed yet. Run: ./deploy-compute-engine.sh" -ForegroundColor Red
}

Write-Host ""
Write-Host "📋 Mobile Testing Instructions:" -ForegroundColor Yellow
Write-Host "===============================" -ForegroundColor Yellow
Write-Host "1. Make sure your mobile is on the same WiFi network as your computer" -ForegroundColor White
Write-Host "2. Use the IP addresses/URLs above in your mobile browser" -ForegroundColor White
Write-Host "3. For API testing, use: http://[IP]/docs (Swagger UI)" -ForegroundColor White
Write-Host "4. For frontend, deploy frontend to a public URL (see GCP_DEPLOYMENT_GUIDE.md)" -ForegroundColor White

Write-Host ""
Write-Host "🔧 Quick Test Commands:" -ForegroundColor Yellow
Write-Host "======================" -ForegroundColor Yellow
Write-Host "# Test API from mobile (replace with actual IP/URL):" -ForegroundColor Gray
Write-Host "Invoke-WebRequest -Uri 'http://[IP]/api/pose' -Method POST -ContentType 'application/json' -Body '{\"image\":\"base64_encoded_image\",\"file_name\":\"test.jpg\"}'" -ForegroundColor White

Write-Host ""
Write-Host "📱 Mobile Browser Testing:" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow
Write-Host "1. Open mobile browser" -ForegroundColor White
Write-Host "2. Navigate to: http://[IP]/docs" -ForegroundColor White
Write-Host "3. Test the API endpoints using Swagger UI" -ForegroundColor White 