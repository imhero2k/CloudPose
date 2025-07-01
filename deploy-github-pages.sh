#!/bin/bash

# CloudPose GitHub Pages Deployment Script
echo "🚀 Deploying CloudPose Frontend to GitHub Pages..."

# Check if we're in the right directory
if [ ! -f "frontend/package.json" ]; then
    echo "❌ Error: frontend/package.json not found. Make sure you're in the project root."
    exit 1
fi

# Build the frontend
echo "🔨 Building frontend..."
cd frontend
npm run build
cd ..

# Create a temporary directory for deployment
echo "📁 Preparing deployment files..."
rm -rf deploy-temp
mkdir deploy-temp
cp -r frontend/build/* deploy-temp/

# Create a simple index.html redirect if needed
cat > deploy-temp/404.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>CloudPose - Page Not Found</title>
    <script>
        // Single Page Apps for GitHub Pages
        // https://github.com/rafgraph/spa-github-pages
        var pathSegmentsToKeep = 0;
        var l = window.location;
        l.replace(
            l.protocol + '//' + l.hostname + (l.port ? ':' + l.port : '') +
            l.pathname.split('/').slice(0, 1 + pathSegmentsToKeep).join('/') + '/?/' +
            l.pathname.slice(1).split('/').slice(pathSegmentsToKeep).join('/').replace(/&/g, '~and~') +
            (l.search ? '&' + l.search.slice(1).replace(/&/g, '~and~') : '') +
            l.hash
        );
    </script>
</head>
<body>
    Redirecting...
</body>
</html>
EOF

cat > deploy-temp/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>CloudPose - Redirecting</title>
    <script>
        // Single Page Apps for GitHub Pages
        // https://github.com/rafgraph/spa-github-pages
        (function(l) {
            if (l.search[1] === '/' ) {
                var decoded = l.search.slice(1).split('&').map(function(s) { 
                    return s.replace(/~and~/g, '&')
                }).join('?');
                window.history.replaceState(null, null,
                    l.pathname.slice(0, -1) + decoded + l.hash
                );
            }
        }(window.location))
    </script>
</head>
<body>
    Loading CloudPose...
</body>
</html>
EOF

echo "✅ Deployment files prepared!"
echo ""
echo "📋 Next Steps:"
echo "1. Go to your GitHub repository: https://github.com/imhero2k/CloudPose"
echo "2. Go to Settings > Pages"
echo "3. Set Source to 'Deploy from a branch'"
echo "4. Select 'gh-pages' branch and '/ (root)' folder"
echo "5. Click Save"
echo ""
echo "🌐 Your frontend will be available at: https://imhero2k.github.io/CloudPose"
echo ""
echo "📁 Deployment files are in: deploy-temp/"
echo "You can manually upload these files to the gh-pages branch if needed." 