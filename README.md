# CloudPose - FIT5225 Assignment 1

A containerized pose estimation web service deployed on Kubernetes in Oracle Cloud Infrastructure (OCI).

## Project Overview

CloudPose is a RESTful API service that performs pose estimation on images using YOLOv8. The service is containerized with Docker and deployed on a Kubernetes cluster in OCI. It provides two endpoints:
- `/api/pose` - Returns JSON with detected keypoints
- `/api/pose/annotated` - Returns an annotated image with keypoints drawn

## Architecture

- **Web Service**: FastAPI-based REST API
- **Model**: YOLOv8 pose estimation model
- **Containerization**: Docker
- **Orchestration**: Kubernetes cluster on OCI
- **Load Testing**: Locust for performance testing

## Repository Structure

```
CloudPose/
├── app/                     # Main application code
│   ├── app.py              # FastAPI web service
│   └── requirements.txt    # Python dependencies
├── frontend/               # React frontend application
│   ├── src/                # React source code
│   ├── public/             # Static files
│   └── package.json        # Frontend dependencies
├── k8s/                    # Kubernetes configurations
│   ├── deployment.yaml     # Pod deployment configuration
│   └── service.yaml        # Service configuration
├── load-testing/           # Load testing scripts
│   ├── locustfile.py       # Locust test scenarios
│   └── Automation.py       # Automated experiment runner
├── docker/                 # Docker configuration
│   └── Dockerfile          # Container definition
├── docs/                   # Documentation
│   └── README.md           # This file
└── README.md               # Main README
```

## Quick Start

### Prerequisites

- Python 3.9+
- Node.js (v14 or higher) - for frontend
- Docker
- Kubernetes cluster (OCI)
- Locust (for load testing)

### Local Development

The published Oracle VM backend is not required. Run the API on this machine, then point the React app at `http://localhost:60000`.

1. Create a virtualenv and install dependencies:
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r app/requirements.txt
```

2. Run the service locally (loads `app/yolov8n-pose.pt`):
```bash
python app/app.py
```

Or use the helper script:
```bash
chmod +x run-local.sh
./run-local.sh
```

3. Health check and API docs:
```bash
curl http://localhost:60000/health
# Swagger UI: http://localhost:60000/docs
```

4. Test pose estimation (replace the image path):
```bash
python - <<'PY'
import base64, json, pathlib, urllib.request
img = base64.b64encode(pathlib.Path("samples/person.jpg").read_bytes()).decode()
req = urllib.request.Request(
    "http://localhost:60000/api/pose",
    data=json.dumps({"image": img, "id": "test-123", "file_name": "person.jpg"}).encode(),
    headers={"Content-Type": "application/json"},
)
print(urllib.request.urlopen(req).read().decode())
PY
```

### Frontend Development

1. Install frontend dependencies:
```bash
cd frontend
npm install
```

2. The UI reads `REACT_APP_API_URL` (default `http://localhost:60000`). Copy the example env if you need to override it:
```bash
cp ../.env.example .env.local
```

3. Start the React development server:
```bash
npm start
```

4. Open `http://localhost:3000/CloudPose`, upload an image, and try **Get Keypoints** and **Get Annotated Image**.

### Tests

API unit tests mock YOLOv8 so they do not need Torch or the `.pt` weights:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
pytest
```

Frontend tests:

```bash
cd frontend
npm ci
CI=true npm test -- --watchAll=false
```

GitHub Actions workflow `.github/workflows/ci.yml` runs both suites on pushes and pull requests.

### Docker Build

```bash
docker build -f docker/Dockerfile -t cloudpose:latest .
```

### Kubernetes Deployment

1. Apply the deployment:
```bash
kubectl apply -f k8s/deployment.yaml
```

2. Apply the service:
```bash
kubectl apply -f k8s/service.yaml
```

3. Check deployment status:
```bash
kubectl get pods -n assignment1
kubectl get services -n assignment1
```

### Load Testing

1. Install Locust:
```bash
pip install locust
```

2. Run load tests:
```bash
locust -f load-testing/locustfile.py --host=http://your-service-url
```

3. Run automated experiments:
```bash
python load-testing/Automation.py
```

## API Endpoints

### POST /api/pose

Returns JSON with detected pose keypoints.

**Request:**
```json
{
  "id": "unique-request-id",
  "image": "base64_encoded_image",
  "file_name": "image.jpg"
}
```

**Response:**
```json
{
  "id": "unique-request-id",
  "count": 1,
  "boxes": [
    {
      "x": 100.0,
      "y": 200.0,
      "width": 150.0,
      "height": 300.0,
      "probability": 0.95
    }
  ],
  "keypoints": [
    [
      [x1, y1, confidence1],
      [x2, y2, confidence2],
      ...
    ]
  ],
  "processing_time": "0.15s",
  "file_name": "image.jpg"
}
```

### POST /api/pose/annotated

Returns an annotated image with keypoints drawn.

**Request:** Same as `/api/pose`

**Response:**
```json
{
  "id": "unique-request-id",
  "image": "base64_encoded_annotated_image",
  "file_name": "image.jpg",
  "message": "Pose annotated successfully"
}
```

## Configuration

### Environment Variables

- `PORT`: API listen port (default: `60000` locally, `80` in Docker)
- `YOLO_MODEL_PATH`: Optional override for the YOLOv8 pose weights
- `CORS_ORIGINS`: Comma-separated browser origins, or `*` to allow all
- `REACT_APP_API_URL`: Frontend API base URL (default: `http://localhost:60000`)
- `SERVICE_URL`: Target URL for load testing (default: http://207.211.146.57:30080)
- `IMAGE_DIR`: Directory containing test images (default: "image")

### Kubernetes Resources

- CPU Request/Limit: 0.5 cores
- Memory Request/Limit: 512MiB
- Port: 80 (container), 30080 (NodePort)

## Performance Testing

The system has been tested with varying numbers of pods (1, 2, 4, 8) and concurrent users to determine optimal performance characteristics.

### Test Results

Results are stored in `load-testing/remote_results/experiment_results.csv` and include:
- Maximum concurrent users before failure
- Average response time
- Success rate

## Troubleshooting

### Common Issues

1. **Pod startup failures**: Check resource limits and image availability
2. **Service connectivity**: Verify NodePort configuration and firewall rules
3. **Load testing failures**: Ensure test images are available and service is accessible

### Logs

```bash
# Pod logs
kubectl logs -f deployment/pose-estimator -n assignment1

# Service logs
kubectl describe service pose-estimator-service -n assignment1
```
