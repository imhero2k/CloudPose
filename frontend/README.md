# CloudPose Frontend

A modern React frontend for the CloudPose AI pose estimation service.

## Features

- 🖼️ **Image Upload**: Drag and drop or click to upload images
- 🔍 **Pose Detection**: Get detailed keypoints and bounding boxes
- 🎨 **Annotated Images**: View images with pose keypoints drawn
- 📊 **Real-time Results**: See processing statistics and raw JSON data
- 📱 **Responsive Design**: Works on desktop and mobile devices
- 🎯 **Modern UI**: Beautiful gradient design with smooth animations

## Quick Start

### Prerequisites

- Node.js (v14 or higher)
- npm or yarn
- CloudPose backend running on `http://localhost:60000`

### Installation

1. **Install dependencies:**
   ```bash
   cd frontend
   npm install
   ```

2. **Start the development server:**
   ```bash
   npm start
   ```

3. **Open your browser:**
   Navigate to `http://localhost:3000`

### Usage

1. **Upload an Image:**
   - Click the upload area or drag and drop an image
   - Supported formats: JPG, PNG, GIF

2. **Get Pose Data:**
   - Click "🔍 Get Keypoints" to receive JSON with pose information
   - View statistics like number of people detected and processing time

3. **Get Annotated Image:**
   - Click "🎨 Get Annotated Image" to see the image with keypoints drawn
   - Switch between tabs to view different results

## API Endpoints

The frontend connects to these backend endpoints:

- `POST /api/pose` - Returns pose keypoints and bounding boxes
- `POST /api/pose/annotated` - Returns annotated image with keypoints

## Configuration

### Backend URL

The frontend is configured to connect to `http://localhost:60000` by default. To change this:

1. Edit `src/App.js`
2. Update the fetch URLs in `sendPoseRequest()` and `sendAnnotatedRequest()`

### CORS

If you encounter CORS issues, ensure your FastAPI backend has CORS middleware enabled:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Build for Production

```bash
npm run build
```

This creates a `build` folder with optimized production files.

## Technologies Used

- **React 18** - UI framework
- **CSS3** - Modern styling with gradients and animations
- **Fetch API** - HTTP requests to backend
- **FileReader API** - Image to base64 conversion

## Project Structure

```
frontend/
├── public/
│   ├── index.html          # Main HTML file
│   └── manifest.json       # PWA manifest
├── src/
│   ├── App.js              # Main React component
│   ├── App.css             # Styling
│   └── index.js            # React entry point
├── package.json            # Dependencies and scripts
└── README.md               # This file
```

## Troubleshooting

### Common Issues

1. **Backend Connection Error:**
   - Ensure your FastAPI backend is running on port 60000
   - Check that CORS is properly configured

2. **Image Upload Issues:**
   - Verify the image format is supported
   - Check browser console for errors

3. **Build Errors:**
   - Clear node_modules and reinstall: `rm -rf node_modules && npm install`

### Development Tips

- Use browser developer tools to inspect network requests
- Check the browser console for JavaScript errors
- Test with different image sizes and formats

## Contributing

This frontend is part of the FIT5225 Cloud Computing Assignment 1. For any issues or improvements, please refer to the main project documentation.

---

**Student**: [Your Name]  
**Student ID**: [Your Student ID]  
**Course**: FIT5225 Cloud Computing - Semester 1, 2025
