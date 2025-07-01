# 🌐 GitHub Pages Setup Guide for CloudPose

This guide will help you deploy your CloudPose frontend to GitHub Pages, making it accessible from anywhere including your mobile device.

## 🚀 **Quick Setup (Recommended)**

### **Step 1: Enable GitHub Pages**

1. **Go to your repository**: https://github.com/imhero2k/CloudPose
2. **Navigate to Settings**: Click on the "Settings" tab
3. **Find Pages section**: Scroll down to "Pages" in the left sidebar
4. **Configure Pages**:
   - **Source**: Select "Deploy from a branch"
   - **Branch**: Select "gh-pages" (will be created automatically)
   - **Folder**: Select "/ (root)"
   - **Click Save**

### **Step 2: Trigger Deployment**

The GitHub Actions workflow will automatically deploy when you push to master. If you want to trigger it manually:

1. **Go to Actions tab**: https://github.com/imhero2k/CloudPose/actions
2. **Select the workflow**: "Deploy Frontend to GitHub Pages"
3. **Click "Run workflow"**: Choose master branch and run

### **Step 3: Access Your Frontend**

Once deployed, your frontend will be available at:
```
https://imhero2k.github.io/CloudPose
```

## 📱 **Mobile Access**

### **Frontend URL**
- **GitHub Pages**: https://imhero2k.github.io/CloudPose
- **Accessible from**: Any device with internet connection

### **Backend API**
You'll need to deploy your backend to get a public API URL. Use one of these options:

1. **Cloud Run** (Recommended):
   ```bash
   ./deploy-cloudrun.sh
   ```

2. **GKE**:
   ```bash
   ./deploy-gcp.sh
   ```

3. **Compute Engine**:
   ```bash
   ./deploy-compute-engine.sh
   ```

## 🔧 **Manual Deployment (Alternative)**

If the automatic deployment doesn't work, you can deploy manually:

### **Step 1: Build the Frontend**
```bash
cd frontend
npm run build
cd ..
```

### **Step 2: Create gh-pages Branch**
```bash
# Create and switch to gh-pages branch
git checkout --orphan gh-pages

# Remove all files except build
git rm -rf .
git checkout master -- frontend/build

# Move build files to root
mv frontend/build/* .
rmdir frontend/build frontend

# Commit and push
git add .
git commit -m "Deploy to GitHub Pages"
git push origin gh-pages

# Switch back to master
git checkout master
```

### **Step 3: Configure Pages**
1. Go to repository Settings > Pages
2. Set Source to "Deploy from a branch"
3. Select "gh-pages" branch
4. Click Save

## 🔄 **Update Frontend API URL**

Once you have your backend deployed, update the frontend to use the correct API URL:

### **For Cloud Run**
```javascript
// In frontend/src/App.js, update the fetch URLs:
const response = await fetch('https://your-cloudrun-url/api/pose', {
```

### **For GKE/Compute Engine**
```javascript
// In frontend/src/App.js, update the fetch URLs:
const response = await fetch('http://your-external-ip/api/pose', {
```

## 📊 **Testing Your Deployment**

### **Frontend Testing**
1. **Open**: https://imhero2k.github.io/CloudPose
2. **Upload an image**: Test the file upload functionality
3. **Check console**: Look for any API connection errors

### **API Testing**
1. **Swagger UI**: Visit your backend URL + `/docs`
2. **Example**: `https://your-backend-url/docs`
3. **Test endpoints**: Use the interactive Swagger interface

## 🆘 **Troubleshooting**

### **Common Issues**

1. **404 Error on GitHub Pages**:
   - Check if gh-pages branch exists
   - Verify Pages source is set correctly
   - Wait a few minutes for deployment

2. **Frontend can't connect to API**:
   - Check CORS configuration in backend
   - Verify API URL is correct
   - Ensure backend is deployed and running

3. **Build fails**:
   - Check GitHub Actions logs
   - Verify all dependencies are in package.json
   - Check for syntax errors in React code

### **Debugging Steps**

1. **Check GitHub Actions**:
   - Go to Actions tab
   - Click on the latest workflow run
   - Check for error messages

2. **Check Pages Settings**:
   - Verify branch selection
   - Check if custom domain is configured correctly

3. **Test locally first**:
   ```bash
   cd frontend
   npm start
   # Test on localhost:3000
   ```

## 📈 **Next Steps**

1. **Deploy Backend**: Use one of the GCP deployment scripts
2. **Update API URL**: Modify frontend to use your backend URL
3. **Test End-to-End**: Upload images and test pose estimation
4. **Monitor Performance**: Check GitHub Pages analytics
5. **Add Custom Domain**: (Optional) Configure a custom domain

## 🔗 **Useful Links**

- **Repository**: https://github.com/imhero2k/CloudPose
- **GitHub Pages**: https://imhero2k.github.io/CloudPose
- **Actions**: https://github.com/imhero2k/CloudPose/actions
- **Settings**: https://github.com/imhero2k/CloudPose/settings

## 📱 **Mobile Testing**

Once deployed, you can test on your mobile:

1. **Open browser** on your mobile
2. **Navigate to**: https://imhero2k.github.io/CloudPose
3. **Upload an image** from your mobile camera/gallery
4. **Test pose estimation** functionality

The frontend will be fully responsive and work on mobile devices! 