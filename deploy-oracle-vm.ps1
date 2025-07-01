# CloudPose Oracle VM Deployment Script for Windows
Write-Host "🚀 CloudPose Oracle VM Deployment Guide" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

Write-Host ""
Write-Host "📋 Prerequisites:" -ForegroundColor Yellow
Write-Host "1. Oracle Cloud VM instance created" -ForegroundColor White
Write-Host "2. SSH access to your Oracle VM" -ForegroundColor White
Write-Host "3. Public IP address of your Oracle VM" -ForegroundColor White

Write-Host ""
Write-Host "🔧 Step 1: Create Oracle VM Instance" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "1. Go to Oracle Cloud Console" -ForegroundColor White
Write-Host "2. Create a new VM instance:" -ForegroundColor White
Write-Host "   - Shape: VM.Standard2.1 (1 OCPU, 6GB RAM)" -ForegroundColor Gray
Write-Host "   - OS: Ubuntu 20.04 or 22.04" -ForegroundColor Gray
Write-Host "   - Network: Public subnet" -ForegroundColor Gray
Write-Host "   - Security: Open port 80 and 60000" -ForegroundColor Gray

Write-Host ""
Write-Host "🔗 Step 2: Connect to Oracle VM" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
Write-Host "SSH into your Oracle VM:" -ForegroundColor White
Write-Host "ssh ubuntu@YOUR_ORACLE_VM_IP" -ForegroundColor Gray

Write-Host ""
Write-Host "📥 Step 3: Deploy Backend" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host "Run these commands on your Oracle VM:" -ForegroundColor White

Write-Host ""
Write-Host "1. Update system:" -ForegroundColor Yellow
Write-Host "sudo apt-get update && sudo apt-get upgrade -y" -ForegroundColor Gray

Write-Host ""
Write-Host "2. Install Docker:" -ForegroundColor Yellow
Write-Host "sudo apt-get install -y docker.io" -ForegroundColor Gray
Write-Host "sudo systemctl start docker" -ForegroundColor Gray
Write-Host "sudo systemctl enable docker" -ForegroundColor Gray
Write-Host "sudo usermod -aG docker `$USER" -ForegroundColor Gray

Write-Host ""
Write-Host "3. Clone repository:" -ForegroundColor Yellow
Write-Host "git clone https://github.com/imhero2k/CloudPose.git" -ForegroundColor Gray
Write-Host "cd CloudPose" -ForegroundColor Gray

Write-Host ""
Write-Host "4. Build and run Docker container:" -ForegroundColor Yellow
Write-Host "docker build -t cloudpose-backend -f docker/Dockerfile ." -ForegroundColor Gray
Write-Host "docker run -d --name cloudpose-backend -p 60000:80 --restart unless-stopped cloudpose-backend" -ForegroundColor Gray

Write-Host ""
Write-Host "5. Check status:" -ForegroundColor Yellow
Write-Host "docker ps" -ForegroundColor Gray
Write-Host "curl ifconfig.me" -ForegroundColor Gray

Write-Host ""
Write-Host "🔧 Step 4: Update Frontend" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host "Once you have your Oracle VM IP, update the frontend:" -ForegroundColor White

Write-Host ""
Write-Host "1. Edit frontend/src/App.js:" -ForegroundColor Yellow
Write-Host "   Replace 'http://localhost:60000' with 'http://YOUR_ORACLE_VM_IP:60000'" -ForegroundColor Gray

Write-Host ""
Write-Host "2. Rebuild and redeploy frontend:" -ForegroundColor Yellow
Write-Host "cd frontend" -ForegroundColor Gray
Write-Host "npm run build" -ForegroundColor Gray
Write-Host "cd .." -ForegroundColor Gray
Write-Host "git add ." -ForegroundColor Gray
Write-Host "git commit -m 'Update backend URL to Oracle VM'" -ForegroundColor Gray
Write-Host "git push origin master" -ForegroundColor Gray

Write-Host ""
Write-Host "🌐 Step 5: Test Your Application" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
Write-Host "Frontend: https://imhero2k.github.io/CloudPose" -ForegroundColor White
Write-Host "Backend API: http://YOUR_ORACLE_VM_IP:60000/docs" -ForegroundColor White

Write-Host ""
Write-Host "📱 Mobile Testing:" -ForegroundColor Yellow
Write-Host "Open https://imhero2k.github.io/CloudPose on your mobile" -ForegroundColor White
Write-Host "Upload an image and test pose estimation!" -ForegroundColor White

Write-Host ""
Write-Host "🔧 Troubleshooting:" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
Write-Host "1. Check if container is running: docker ps" -ForegroundColor Gray
Write-Host "2. Check container logs: docker logs cloudpose-backend" -ForegroundColor Gray
Write-Host "3. Check firewall: sudo ufw status" -ForegroundColor Gray
Write-Host "4. Open port if needed: sudo ufw allow 60000" -ForegroundColor Gray 