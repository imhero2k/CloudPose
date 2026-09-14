import React, { useState } from 'react';
import './App.css';

// Empty or "/" means same-origin (EKS nginx proxies /api). Unset defaults to local API.
const API_BASE = (
  process.env.REACT_APP_API_URL === undefined
    ? 'http://localhost:60000'
    : process.env.REACT_APP_API_URL
).replace(/\/$/, '')

function App() {
  const [selectedImage, setSelectedImage] = useState(null);
  const [imagePreview, setImagePreview] = useState(null);
  const [poseData, setPoseData] = useState(null);
  const [annotatedImage, setAnnotatedImage] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [activeTab, setActiveTab] = useState('pose');

  const handleImageUpload = (event) => {
    const file = event.target.files[0];
    if (file) {
      setSelectedImage(file);
      const reader = new FileReader();
      reader.onload = (e) => {
        setImagePreview(e.target.result);
      };
      reader.readAsDataURL(file);
      setPoseData(null);
      setAnnotatedImage(null);
      setError(null);
    }
  };

  const convertToBase64 = (file) => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = () => {
        const base64 = reader.result.split(',')[1];
        resolve(base64);
      };
      reader.onerror = (error) => reject(error);
    });
  };

  const postPose = async (path) => {
    const base64Image = await convertToBase64(selectedImage);
    const payload = {
      id: crypto.randomUUID(),
      image: base64Image,
      file_name: selectedImage.name
    };

    const response = await fetch(`${API_BASE}${path}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload)
    });

    if (!response.ok) {
      let detail = `HTTP error! status: ${response.status}`;
      try {
        const body = await response.json();
        if (body.error) detail = body.error;
      } catch {
        // keep status text
      }
      throw new Error(detail);
    }

    return response.json();
  };

  const sendPoseRequest = async () => {
    if (!selectedImage) {
      setError('Please select an image first');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const data = await postPose('/api/pose');
      setPoseData(data);
      setActiveTab('pose');
    } catch (err) {
      setError(`Error: ${err.message}`);
    } finally {
      setLoading(false);
    }
  };

  const sendAnnotatedRequest = async () => {
    if (!selectedImage) {
      setError('Please select an image first');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const data = await postPose('/api/pose/annotated');
      if (data.image) {
        setAnnotatedImage(`data:image/jpeg;base64,${data.image}`);
      }
      setActiveTab('annotated');
    } catch (err) {
      setError(`Error: ${err.message}`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🤖 CloudPose</h1>
        <p>AI-Powered Pose Estimation Web Service</p>
      </header>

      <main className="App-main">
        <div className="upload-section">
          <div className="upload-area">
            <input
              type="file"
              id="image-upload"
              accept="image/*"
              onChange={handleImageUpload}
              className="file-input"
            />
            <label htmlFor="image-upload" className="upload-label">
              {imagePreview ? (
                <img src={imagePreview} alt="Preview" className="image-preview" />
              ) : (
                <div className="upload-placeholder">
                  <span>📁</span>
                  <p>Click to upload an image</p>
                  <p className="upload-hint">Supports JPG, PNG, GIF</p>
                </div>
              )}
            </label>
          </div>

          {selectedImage && (
            <div className="action-buttons">
              <button
                onClick={sendPoseRequest}
                disabled={loading}
                className="btn btn-primary"
              >
                {loading ? '🔄 Processing...' : '🔍 Get Keypoints'}
              </button>
              <button
                onClick={sendAnnotatedRequest}
                disabled={loading}
                className="btn btn-secondary"
              >
                {loading ? '🔄 Processing...' : '🎨 Get Annotated Image'}
              </button>
            </div>
          )}
        </div>

        {error && (
          <div className="error-message">
            <span>❌ {error}</span>
          </div>
        )}

        <div className="results-section">
          <div className="tab-buttons">
            <button
              className={`tab-btn ${activeTab === 'pose' ? 'active' : ''}`}
              onClick={() => setActiveTab('pose')}
            >
              📊 Pose Data
            </button>
            <button
              className={`tab-btn ${activeTab === 'annotated' ? 'active' : ''}`}
              onClick={() => setActiveTab('annotated')}
            >
              🖼️ Annotated Image
            </button>
          </div>

          <div className="tab-content">
            {activeTab === 'pose' && poseData && (
              <div className="pose-data">
                <h3>Pose Estimation Results</h3>
                <div className="stats-grid">
                  <div className="stat-item">
                    <span className="stat-label">People Detected:</span>
                    <span className="stat-value">{poseData.count}</span>
                  </div>
                  <div className="stat-item">
                    <span className="stat-label">Processing Time:</span>
                    <span className="stat-value">{poseData.processing_time}</span>
                  </div>
                </div>
                <div className="json-display">
                  <h4>Raw JSON Response:</h4>
                  <pre>{JSON.stringify(poseData, null, 2)}</pre>
                </div>
              </div>
            )}

            {activeTab === 'annotated' && annotatedImage && (
              <div className="annotated-image">
                <h3>Annotated Image</h3>
                <img src={annotatedImage} alt="Annotated" className="result-image" />
              </div>
            )}

            {!poseData && !annotatedImage && (
              <div className="no-results">
                <p>👆 Upload an image and click one of the buttons above to see results</p>
              </div>
            )}
          </div>
        </div>
      </main>

      <footer className="App-footer">
        <p>FIT5225 Cloud Computing Assignment 1 - CloudPose</p>
      </footer>
    </div>
  );
}

export default App;
