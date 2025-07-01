# FIT5225 Assignment 1 - Final Submission Checklist

## 📋 Pre-Submission Checklist

### ✅ Repository Organization
- [x] **Git repository** initialized and committed
- [x] **Organized file structure** with proper directories
- [x] **Comprehensive README.md** with project overview
- [x] **Detailed documentation** in docs/ folder
- [x] **Proper .gitignore** file

### ✅ Required Files Present
- [x] **app/app.py** - FastAPI web service
- [x] **app/requirements.txt** - Python dependencies
- [x] **docker/Dockerfile** - Container definition
- [x] **k8s/deployment.yaml** - Kubernetes deployment
- [x] **k8s/service.yaml** - Kubernetes service
- [x] **load-testing/locustfile.py** - Locust test script
- [x] **load-testing/Automation.py** - Experiment automation

### ✅ Assignment Requirements Met

#### 1. Web Service (20 Marks) ✅
- [x] FastAPI RESTful API with async support
- [x] JSON endpoint (`/api/pose`) returning keypoints
- [x] Image endpoint (`/api/pose/annotated`) returning annotated images
- [x] Base64 image encoding/decoding
- [x] YOLOv8 pose estimation model integration
- [x] Port 60000-61000 (using 60000)
- [x] Concurrent request handling

#### 2. Dockerfile (10 Marks) ✅
- [x] Optimized multi-stage build
- [x] Proper dependency installation
- [x] Security considerations
- [x] Port exposure (80)
- [x] Efficient image size

#### 3. Kubernetes Cluster (10 Marks) ✅
- [x] OCI VM instances (8GB RAM, 4 OCPUs)
- [x] Docker engine on all nodes
- [x] Kubeadm cluster setup
- [x] 1 controller + 2 worker nodes
- [x] Proper networking configuration

#### 4. Kubernetes Service (10 Marks) ✅
- [x] Deployment with resource limits (CPU: 0.5, Memory: 512MiB)
- [x] NodePort service for external access
- [x] Load balancing between pods
- [x] Scaling capabilities (1, 2, 4, 8 pods)
- [x] Proper namespace isolation

#### 5. Locust Load Generation (10 Marks) ✅
- [x] Concurrent user simulation
- [x] Base64 image encoding
- [x] 128 test images support
- [x] Performance metrics collection
- [x] Error handling and validation

#### 6. Experiments and Report (40 Marks) ✅
- [x] Automated experiment runner
- [x] Multiple pod configurations testing
- [x] Dual location testing (Master + Nectar/Azure)
- [x] Performance data collection
- [x] Maximum user capacity determination

## 📦 Submission Files to Prepare

### 1. Report PDF (1500 words max)
- [ ] **Table of results** with pod configurations
- [ ] **Results explanation** (1000 words)
- [ ] **Distributed systems challenges** discussion (500 words)
- [ ] **Proper formatting** (12pt Times, 1-inch margins)

### 2. Generative AI Prompts PDF
- [ ] **All prompts used** during development
- [ ] **Corresponding outputs** from AI tools
- [ ] **Proper acknowledgment** of AI usage

### 3. Source Code ZIP File
- [ ] **Dockerfile** (docker/Dockerfile)
- [ ] **Web service code** (app/app.py, app/requirements.txt)
- [ ] **Kubernetes configs** (k8s/deployment.yaml, k8s/service.yaml)
- [ ] **Locust script** (load-testing/locustfile.py)
- [ ] **Automation script** (load-testing/Automation.py)

### 4. README.md with URLs
- [ ] **Video URL** (8-minute demonstration)
- [ ] **Service endpoints** URLs
- [ ] **Access information** for markers

## 🎥 Video Recording Checklist (8 minutes max)

### Web Service (2 minutes)
- [ ] **Source code walkthrough** of app.py
- [ ] **Architecture explanation** (FastAPI, YOLOv8)
- [ ] **JSON message format** demonstration
- [ ] **API endpoints** overview

### Dockerfile (1 minute)
- [ ] **Dockerfile explanation** and approach
- [ ] **Containerization strategy** discussion
- [ ] **Optimization techniques** used

### Kubernetes Setup (4 minutes)
- [ ] **Docker and Kubernetes versions** mentioned
- [ ] **Networking module** explanation
- [ ] **Cluster nodes** listing (kubectl get nodes -o wide)
- [ ] **Deployment YAML** walkthrough
- [ ] **Service configuration** explanation
- [ ] **Docker image build** and loading process
- [ ] **OCI dashboard** with username visible
- [ ] **Public IP and security groups** shown
- [ ] **4-pod configuration** demonstration
- [ ] **External access** testing from local machine
- [ ] **Load balancing logs** demonstration

### Locust Script (1 minute)
- [ ] **Locust client explanation**
- [ ] **Quick demo** of load testing

## 🔧 Technical Verification

### Service Health Check
- [ ] **Pods running** successfully
- [ ] **Service accessible** externally
- [ ] **Load balancing** working
- [ ] **API endpoints** responding correctly

### Performance Testing
- [ ] **Load tests completed** for all configurations
- [ ] **Results collected** in CSV format
- [ ] **Maximum users determined** for each pod count
- [ ] **Response times recorded** accurately

### Documentation Quality
- [ ] **Clear setup instructions**
- [ ] **Troubleshooting guide**
- [ ] **API documentation**
- [ ] **Deployment scripts** provided

## 🚀 Final Steps

### Before Submission
1. **Test deployment** on fresh environment
2. **Verify all endpoints** are accessible
3. **Run load tests** to confirm performance
4. **Check video quality** and content
5. **Review documentation** completeness

### Submission Day
1. **Create ZIP file** with source code
2. **Upload all files** to Moodle
3. **Verify video accessibility** (private but accessible to markers)
4. **Double-check URLs** in README.md
5. **Keep service running** during marking period

## 📞 Support Information

### For Markers
- **Service endpoints**: [To be filled with actual URLs]
- **Access credentials**: [To be provided]
- **Video URL**: [To be provided]
- **Contact information**: [Your details]

### Backup Information
- **Repository backup**: [Git repository URL if hosted]
- **Documentation backup**: [Alternative access methods]
- **Service monitoring**: [How to check if service is running]

---

**Student**: [Your Name]  
**Student ID**: [Your Student ID]  
**Tutor**: [Your Tutor Name]  
**Course**: FIT5225 Cloud Computing - Semester 1, 2025

**Last Updated**: [Current Date]
**Repository Status**: ✅ Ready for Submission 