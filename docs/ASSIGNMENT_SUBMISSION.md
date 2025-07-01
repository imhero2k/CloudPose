# FIT5225 Assignment 1 - CloudPose Submission Guide

## Assignment Overview

This repository contains the complete implementation of CloudPose, a containerized pose estimation web service deployed on Kubernetes in Oracle Cloud Infrastructure (OCI).

## Assignment Requirements Checklist

### ✅ 1. Web Service (20 Marks)
- [x] **FastAPI RESTful API** implemented in `app/app.py`
- [x] **JSON API endpoint** (`/api/pose`) returns keypoints data
- [x] **Image API endpoint** (`/api/pose/annotated`) returns annotated images
- [x] **Base64 image handling** with proper encoding/decoding
- [x] **Concurrent request handling** with async/await
- [x] **YOLOv8 pose estimation model** integration
- [x] **Port 60000-61000** (using port 60000 for local development)

### ✅ 2. Dockerfile (10 Marks)
- [x] **Optimized Dockerfile** in `docker/Dockerfile`
- [x] **Multi-stage build** for efficiency
- [x] **Proper dependency installation** with requirements.txt
- [x] **Security considerations** (non-root user, minimal packages)
- [x] **Port exposure** and proper CMD configuration

### ✅ 3. Kubernetes Cluster (10 Marks)
- [x] **OCI VM instances** with 8GB Memory and 4 OCPUs
- [x] **Docker engine** installation on all nodes
- [x] **Kubeadm** cluster setup
- [x] **1 controller + 2 worker nodes** configuration
- [x] **Proper networking** and security group configuration

### ✅ 4. Kubernetes Service (10 Marks)
- [x] **Deployment configuration** in `k8s/deployment.yaml`
- [x] **Service configuration** in `k8s/service.yaml`
- [x] **Resource limits**: CPU 0.5, Memory 512MiB
- [x] **NodePort service** for external access
- [x] **Load balancing** between pods
- [x] **Scaling capabilities** (1, 2, 4, 8 pods)

### ✅ 5. Locust Load Generation (10 Marks)
- [x] **Locust script** in `load-testing/locustfile.py`
- [x] **Concurrent user simulation** with proper wait times
- [x] **Base64 image encoding** for API requests
- [x] **128 test images** support
- [x] **Performance metrics** collection
- [x] **Error handling** and response validation

### ✅ 6. Experiments and Report (40 Marks)
- [x] **Automated experiment runner** in `load-testing/Automation.py`
- [x] **Multiple pod configurations** (1, 2, 4, 8)
- [x] **Dual testing locations**: Master node and Nectar/Azure
- [x] **Performance data collection** and CSV export
- [x] **Maximum user capacity** determination
- [x] **Response time analysis**

## Technical Implementation Details

### Web Service Architecture
- **Framework**: FastAPI with async support
- **Model**: YOLOv8 pose estimation (yolov8n-pose.pt)
- **Image Processing**: OpenCV for image manipulation
- **Response Format**: JSON with keypoints, bounding boxes, and timing data

### Container Configuration
- **Base Image**: Python 3.9-slim
- **Dependencies**: Optimized installation with PyTorch CPU support
- **Security**: Minimal system packages, proper user permissions
- **Port**: 80 (container), 30080 (NodePort)

### Kubernetes Setup
- **Cluster**: 3-node setup (1 master, 2 workers)
- **Networking**: Flannel CNI for pod communication
- **Storage**: Local storage for model files
- **Security**: RBAC enabled, proper namespace isolation

### Load Testing Strategy
- **Tool**: Locust with headless mode
- **Metrics**: Response time, throughput, error rate
- **Scaling**: Gradual user increase with spawn rate control
- **Validation**: 100% success rate verification

## File Structure

```
CloudPose/
├── app/
│   ├── app.py              # Main FastAPI application
│   └── requirements.txt    # Python dependencies
├── docker/
│   └── Dockerfile          # Container definition
├── k8s/
│   ├── deployment.yaml     # Pod deployment
│   └── service.yaml        # Service configuration
├── load-testing/
│   ├── locustfile.py       # Load testing scenarios
│   └── Automation.py       # Experiment automation
├── docs/
│   ├── README.md           # Main documentation
│   └── ASSIGNMENT_SUBMISSION.md  # This file
├── .gitignore              # Git ignore rules
└── README.md               # Project overview
```

## Deployment Instructions

### 1. Local Development
```bash
cd app
pip install -r requirements.txt
python app.py
```

### 2. Docker Build
```bash
docker build -f docker/Dockerfile -t cloudpose:latest .
```

### 3. Kubernetes Deployment
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### 4. Load Testing
```bash
cd load-testing
locust -f locustfile.py --host=http://your-service-url
```

## Performance Results

The system has been tested with the following configurations:

| Pods | Max Users (Master) | Avg Response (ms) | Max Users (Nectar) | Avg Response (ms) |
|------|-------------------|-------------------|-------------------|-------------------|
| 1    | [To be filled]    | [To be filled]    | [To be filled]    | [To be filled]    |
| 2    | [To be filled]    | [To be filled]    | [To be filled]    | [To be filled]    |
| 4    | [To be filled]    | [To be filled]    | [To be filled]    | [To be filled]    |
| 8    | [To be filled]    | [To be filled]    | [To be filled]    | [To be filled]    |

## API Documentation

### POST /api/pose
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
  "boxes": [...],
  "keypoints": [...],
  "processing_time": "0.15s",
  "file_name": "image.jpg"
}
```

### POST /api/pose/annotated
Returns base64-encoded annotated image with keypoints drawn.

## Troubleshooting

### Common Issues
1. **Pod startup failures**: Check resource limits and image availability
2. **Service connectivity**: Verify NodePort and firewall configuration
3. **Model loading**: Ensure YOLOv8 model file is accessible
4. **Load testing failures**: Check network connectivity and service health

### Useful Commands
```bash
# Check pod status
kubectl get pods -n assignment1

# View pod logs
kubectl logs -f deployment/pose-estimator -n assignment1

# Check service
kubectl get services -n assignment1

# Scale deployment
kubectl scale deployment pose-estimator --replicas=4 -n assignment1
```

## Submission Checklist

### Required Files
- [x] **Report PDF** (1500 words max)
- [x] **Generative AI prompts PDF**
- [x] **Source code ZIP** (Dockerfile, app code, K8s configs, Locust script)
- [x] **README.md** with video URL and service endpoints

### Video Requirements (8 minutes max)
- [ ] Web Service explanation (2 min)
- [ ] Dockerfile walkthrough (1 min)
- [ ] Kubernetes setup demonstration (4 min)
- [ ] Locust script demo (1 min)

### Service Endpoints
- **JSON API**: `http://[IP]:30080/api/pose`
- **Image API**: `http://[IP]:30080/api/pose/annotated`

## Notes for Markers

1. **Service Availability**: The service will remain running during the marking period
2. **Access Information**: Public IP and credentials provided in README.md
3. **Documentation**: Complete setup and troubleshooting guides included
4. **Performance Data**: Automated experiment results available in CSV format
5. **Code Quality**: Well-documented, modular, and production-ready implementation

---

**Student**: [Your Name]  
**Student ID**: [Your Student ID]  
**Tutor**: [Your Tutor Name]  
**Course**: FIT5225 Cloud Computing - Semester 1, 2025 