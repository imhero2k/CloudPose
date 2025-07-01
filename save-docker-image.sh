#!/bin/bash

# Save CloudPose Docker Image
echo "💾 Saving CloudPose Docker image..."

# Save the image to a tar file
docker save cloudpose-backend > cloudpose-backend.tar

# Get file size
FILE_SIZE=$(du -h cloudpose-backend.tar | cut -f1)

echo "✅ Docker image saved successfully!"
echo "📁 File: cloudpose-backend.tar"
echo "📏 Size: $FILE_SIZE"
echo ""
echo "🚀 Next steps:"
echo "1. Copy this file to your Oracle VM:"
echo "   scp cloudpose-backend.tar ubuntu@YOUR_ORACLE_VM_IP:~/"
echo ""
echo "2. On Oracle VM, load the image:"
echo "   docker load < cloudpose-backend.tar"
echo ""
echo "3. Run the container:"
echo "   docker run -d --name cloudpose-backend -p 60000:80 --restart unless-stopped cloudpose-backend"
echo ""
echo "4. Update frontend with Oracle VM IP:"
echo "   Replace 'YOUR_ORACLE_VM_IP' in frontend/src/App.js with actual IP" 