# 🚀 Oracle VM + GitHub Pages Deployment Guide

This guide will help you deploy CloudPose with:
- **Backend**: Docker container on Oracle VM
- **Frontend**: GitHub Pages
- **Mobile Access**: Available from anywhere

## 📋 **Prerequisites**

1. **Oracle Cloud Account**: Sign up at [cloud.oracle.com](https://cloud.oracle.com)
2. **GitHub Repository**: Your CloudPose repo at [github.com/imhero2k/CloudPose](https://github.com/imhero2k/CloudPose)
3. **SSH Client**: For connecting to Oracle VM

## 🏗️ **Step 1: Create Oracle VM Instance**

### **A. Oracle Cloud Console Setup**
1. **Login to Oracle Cloud Console**
2. **Navigate to Compute > Instances**
3. **Click "Create Instance"**

### **B. Instance Configuration**
- **Name**: `cloudpose-backend`
- **Shape**: `VM.Standard2.1` (1 OCPU, 6GB RAM)
- **Image**: `Canonical Ubuntu 22.04`
- **Network**: `Public subnet`
- **Public IP**: `Yes`

### **C. Security Configuration**
1. **Create Security List**:
   - **Ingress Rule 1**: Port 22 (SSH) - Source 0.0.0.0/0
   - **Ingress Rule 2**: Port 60000 (App) - Source 0.0.0.0/0
   - **Ingress Rule 3**: Port 80 (HTTP) - Source 0.0.0.0/0

2. **Assign to VM**: Select your security list

### **D. Launch Instance**
- Click "Create"
- Note your **Public IP Address**

## 🔗 **Step 2: Connect to Oracle VM**

```bash
# SSH into your Oracle VM
ssh ubuntu@YOUR_ORACLE_VM_IP

# Example:
ssh ubuntu@150.136.123.45
```

## 🐳 **Step 3: Deploy Backend to Oracle VM**

### **A. Update System and Install Docker**
```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Logout and login again, or run:
newgrp docker
```

### **B. Clone Repository**
```bash
# Clone your repository
git clone https://github.com/imhero2k/CloudPose.git
cd CloudPose
```

### **C. Build and Run Docker Container**
```bash
# Build Docker image
docker build -t cloudpose-backend -f docker/Dockerfile .

# Run container
docker run -d \
    --name cloudpose-backend \
    -p 60000:80 \
    --restart unless-stopped \
    cloudpose-backend
```

### **D. Verify Deployment**
```bash
# Check if container is running
docker ps

# Check container logs
docker logs cloudpose-backend

# Get your public IP
curl ifconfig.me
```

## 🌐 **Step 4: Update Frontend for Oracle VM**

### **A. Update API URL**
Edit `frontend/src/App.js` and replace the API URLs:

```javascript
// Replace these lines:
const response = await fetch('http://localhost:60000/api/pose', {

// With your Oracle VM IP:
const response = await fetch('http://YOUR_ORACLE_VM_IP:60000/api/pose', {
```

### **B. Rebuild and Deploy Frontend**
```bash
# Build frontend
cd frontend
npm run build
cd ..

# Commit and push changes
git add .
git commit -m "Update backend URL to Oracle VM"
git push origin master
```

## 📱 **Step 5: Test Your Application**

### **Frontend URLs**
- **GitHub Pages**: https://imhero2k.github.io/CloudPose
- **Mobile Access**: Same URL, works on any device

### **Backend URLs**
- **API Documentation**: http://YOUR_ORACLE_VM_IP:60000/docs
- **Health Check**: http://YOUR_ORACLE_VM_IP:60000/

### **Mobile Testing**
1. **Open browser** on your mobile
2. **Navigate to**: https://imhero2k.github.io/CloudPose
3. **Upload an image** from your mobile camera/gallery
4. **Test pose estimation** functionality

## 🔧 **Troubleshooting**

### **Common Issues**

1. **Container not starting**:
   ```bash
   # Check logs
   docker logs cloudpose-backend
   
   # Restart container
   docker restart cloudpose-backend
   ```

2. **Port not accessible**:
   ```bash
   # Check if port is open
   sudo netstat -tlnp | grep 60000
   
   # Check firewall
   sudo ufw status
   
   # Open port if needed
   sudo ufw allow 60000
   ```

3. **CORS errors**:
   - Verify GitHub Pages URL is in CORS origins
   - Check browser console for specific errors

4. **Frontend not connecting**:
   - Verify Oracle VM IP is correct
   - Check if backend is running: `docker ps`
   - Test API directly: `curl http://YOUR_IP:60000/docs`

### **Useful Commands**

```bash
# Check container status
docker ps

# View container logs
docker logs -f cloudpose-backend

# Restart container
docker restart cloudpose-backend

# Update container (after code changes)
docker stop cloudpose-backend
docker rm cloudpose-backend
docker build -t cloudpose-backend -f docker/Dockerfile .
docker run -d --name cloudpose-backend -p 60000:80 --restart unless-stopped cloudpose-backend

# Check system resources
htop
df -h
free -h
```

## 💰 **Cost Optimization**

### **Oracle VM Costs**
- **VM.Standard2.1**: ~$30-50/month
- **VM.Standard2.2**: ~$60-100/month (if you need more resources)

### **Cost Saving Tips**
1. **Stop VM when not in use** (saves ~70% of costs)
2. **Use preemptible instances** for development
3. **Monitor usage** in Oracle Cloud Console

## 🔒 **Security Considerations**

1. **Firewall**: Only open necessary ports (22, 60000)
2. **SSH Keys**: Use SSH keys instead of passwords
3. **Regular Updates**: Keep system and Docker updated
4. **Monitoring**: Check logs regularly for suspicious activity

## 📊 **Monitoring**

### **System Monitoring**
```bash
# Check system resources
htop
df -h
free -h

# Check Docker resources
docker stats
```

### **Application Monitoring**
```bash
# Check application logs
docker logs -f cloudpose-backend

# Monitor API requests
tail -f /var/log/nginx/access.log  # if using nginx
```

## 🚀 **Scaling Options**

### **Vertical Scaling**
- Upgrade VM shape for more CPU/RAM
- Increase Docker container resources

### **Horizontal Scaling**
- Add load balancer
- Deploy multiple containers
- Use Oracle Container Engine for Kubernetes (OKE)

## 📈 **Next Steps**

1. **Set up monitoring** with Oracle Cloud Monitoring
2. **Configure backups** for your VM
3. **Set up CI/CD** for automatic deployments
4. **Add SSL certificate** for HTTPS
5. **Implement load balancing** for high availability

## 🔗 **Useful Links**

- **Oracle Cloud Console**: https://cloud.oracle.com
- **GitHub Repository**: https://github.com/imhero2k/CloudPose
- **GitHub Pages**: https://imhero2k.github.io/CloudPose
- **Docker Documentation**: https://docs.docker.com
- **Oracle VM Documentation**: https://docs.oracle.com/en-us/iaas/Content/Compute/home.htm

---

**🎉 Congratulations!** Your CloudPose application is now deployed with:
- **Backend**: Running on Oracle VM with Docker
- **Frontend**: Hosted on GitHub Pages
- **Mobile Access**: Available from anywhere in the world 