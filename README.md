# CloudPose

CloudPose is a full-stack pose-estimation application built with FastAPI, YOLOv8, React, Docker, Kubernetes, and Amazon EKS. Upload an image to receive either structured pose keypoints or a JPEG annotated with detected people and body landmarks.

## Contents

- [Product](#product)
- [Architecture](#architecture)
- [Quick start](#quick-start)
- [API](#api)
- [Testing](#testing)
- [Docker](#docker)
- [Amazon EKS](#amazon-eks)
- [Continuous integration and deployment](#continuous-integration-and-deployment)
- [Load testing](#load-testing)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Project structure](#project-structure)

## Product

CloudPose provides:

- `POST /api/pose` — bounding boxes, keypoint coordinates, confidence values, and processing time
- `POST /api/pose/annotated` — a base64-encoded JPEG with boxes and landmarks
- `GET /health` — API and model configuration health information
- `/docs` — interactive OpenAPI/Swagger documentation
- A React UI for image upload, JSON results, and annotated-image display

The default `yolov8n-pose.pt` weights are included under `app/`.

## Architecture

```text
Browser
   |
   v
AWS Network Load Balancer :80
   |
   v
React + nginx Deployment
   |-- /              -> static React application
   |-- /api/*         -> pose-estimator-service
   |-- /health,/docs  -> pose-estimator-service
                         |
                         v
                 FastAPI + YOLOv8 Deployment
```

Terraform creates the VPC, EKS cluster, managed nodes, ECR repositories, Kubernetes workloads, load balancer, and GitHub Actions OIDC deployment role.

## Quick start

### Prerequisites

- Python 3.11 or 3.12
- Node.js 20 and npm
- Git

For containers and AWS deployment:

- Docker with Compose
- Terraform 1.5+
- AWS CLI v2
- `kubectl`

### Clone and configure

```bash
git clone https://github.com/imhero2k/CloudPose.git
cd CloudPose
```

See `.env.example` for supported runtime variables. Export them in your shell or place frontend variables in `frontend/.env.local`.

### Run the API

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r app/requirements.txt
python app/app.py
```

Or:

```bash
./run-local.sh
```

Verify it:

```bash
curl http://localhost:60000/health
```

Swagger UI is available at <http://localhost:60000/docs>.

### Run the frontend

In another terminal:

```bash
cd frontend
npm ci
npm start
```

Open <http://localhost:3000/CloudPose>. The development frontend uses `http://localhost:60000` unless `REACT_APP_API_URL` overrides it.

### Smoke-test pose estimation

With the API running:

```bash
python - <<'PY'
import base64
import json
from pathlib import Path
from urllib.request import Request, urlopen

image = base64.b64encode(Path("samples/person.jpg").read_bytes()).decode()
request = Request(
    "http://localhost:60000/api/pose",
    data=json.dumps({
        "id": "smoke-test",
        "image": image,
        "file_name": "person.jpg"
    }).encode(),
    headers={"Content-Type": "application/json"},
)
print(urlopen(request, timeout=120).read().decode())
PY
```

## API

### Request body

Both pose endpoints accept:

```json
{
  "id": "optional-request-id",
  "image": "base64-encoded-image-or-data-url",
  "file_name": "person.jpg"
}
```

`id` and `file_name` are optional. Invalid images return HTTP `400`; malformed request bodies return HTTP `422`.

### Keypoints response

```json
{
  "id": "request-id",
  "count": 1,
  "boxes": [
    {
      "x": 320.0,
      "y": 240.0,
      "width": 180.0,
      "height": 400.0,
      "probability": 0.95
    }
  ],
  "keypoints": [
    [[100.0, 80.0, 0.98]]
  ],
  "processing_time": "0.15s",
  "file_name": "person.jpg"
}
```

### Annotated response

```json
{
  "id": "request-id",
  "image": "base64-encoded-jpeg",
  "file_name": "person.jpg",
  "message": "Pose annotated successfully"
}
```

## Testing

### Complete local gate

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
cd frontend && npm ci && cd ..
./scripts/pre-push.sh
```

Install it as a Git pre-push hook:

```bash
./scripts/install-git-hooks.sh
```

The local gate checks Python syntax, pytest, Jest, Terraform formatting/validation, and Docker Compose when the relevant tools are installed.

### Individual suites

```bash
# API, infrastructure, and workflow tests (YOLO is mocked)
pytest -q

# Frontend
cd frontend
CI=true npm test -- --watchAll=false
REACT_APP_API_URL=/ PUBLIC_URL=/ npm run build

# Terraform
terraform -chdir=terraform fmt -check -recursive
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform validate
```

## Docker

### API only

```bash
docker build -f docker/Dockerfile -t cloudpose-api:local .
docker run --rm -p 60000:80 cloudpose-api:local
```

### Docker Compose

```bash
docker compose up --build
curl http://localhost:60000/health
docker compose down
```

### Frontend image

```bash
docker build -f docker/Dockerfile.frontend -t cloudpose-frontend:local .
```

The production frontend runs under nginx. It calls `/api` on the same origin; nginx proxies those requests to `pose-estimator-service`.

## Amazon EKS

> EKS, EC2, ECR, and the load balancer incur AWS charges.

### 1. Configure AWS

```bash
aws configure
aws sts get-caller-identity
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Review `terraform.tfvars`. Defaults use:

- Region `ap-southeast-2`
- EKS 1.31
- Two `t3.large` nodes
- API requests/limits of 1 vCPU and 2 GiB
- Kubernetes namespace `cloudpose`

### 2. Create the cluster and registries

Kubernetes resources require the EKS API to exist, so the initial setup is two-stage:

```bash
terraform init
terraform apply \
  -target=aws_eks_cluster.this \
  -target=aws_eks_node_group.this \
  -target=aws_ecr_repository.api \
  -target=aws_ecr_repository.frontend
```

### 3. Push initial images

```bash
../scripts/push-ecr.sh
```

### 4. Deploy workloads

```bash
terraform apply
aws eks update-kubeconfig \
  --region "$(terraform output -raw region)" \
  --name "$(terraform output -raw cluster_name)"
kubectl -n cloudpose get pods,svc
terraform output load_balancer_hostname
```

Open `http://<load_balancer_hostname>/`.

### Destroy the environment

```bash
terraform destroy
```

ECR repositories use `force_delete`; destroying the stack also removes stored images.

See [`terraform/README.md`](terraform/README.md) for infrastructure-specific details.

## Continuous integration and deployment

### Pre-merge checks

`.github/workflows/ci.yml` runs on pull requests and pushes:

- pytest on Python 3.11 and 3.12
- Python compilation checks
- Jest tests and a production React build
- Terraform format and validation
- Hadolint, ShellCheck, actionlint, and Compose validation
- Production frontend container build and nginx configuration check
- A final `Pre-merge gate` that fails unless every required job succeeds

Protect `master` in GitHub and require **Pre-merge gate** before merging.

### Deploy after merge

`.github/workflows/deploy-eks.yml` runs after code reaches `master`:

1. Re-runs API, frontend, and Terraform checks
2. Assumes an AWS IAM role via GitHub OIDC (no long-lived AWS keys)
3. Builds immutable API and frontend images tagged with the commit SHA
4. Pushes SHA and `latest` tags to ECR
5. Updates both EKS Deployments
6. Waits for Kubernetes rollout completion and prints the public URL

#### One-time GitHub setup

After `terraform apply`:

```bash
terraform output -raw github_actions_role_arn
```

Configure [repository Actions settings](https://github.com/imhero2k/CloudPose/settings/secrets/actions):

| Kind | Name | Value |
|---|---|---|
| Secret | `AWS_GHA_ROLE_ARN` | Terraform output above |
| Variable (optional) | `AWS_REGION` | `ap-southeast-2` |
| Variable (optional) | `EKS_CLUSTER_NAME` | `cloudpose` |
| Variable (optional) | `K8S_NAMESPACE` | `cloudpose` |
| Variable (optional) | `ECR_API_NAME` | `cloudpose-api` |
| Variable (optional) | `ECR_FRONTEND_NAME` | `cloudpose-frontend` |

Create a GitHub Environment named **`eks`**. Add required reviewers if production deployment should require approval.

The OIDC trust policy allows only this repository's `master` branch and `eks` environment.

## Load testing

```bash
source .venv/bin/activate
pip install locust
IMAGE_DIR=samples locust \
  -f load-testing/locustfile.py \
  --host=http://localhost:60000
```

Open <http://localhost:8089> to configure users and spawn rate.

For EKS, use the load balancer URL as `--host`. Do not run uncontrolled load against shared or production infrastructure.

## Configuration

| Variable | Component | Default | Purpose |
|---|---|---|---|
| `PORT` | API | `60000` local / `80` container | HTTP listen port |
| `YOLO_MODEL_PATH` | API | `app/yolov8n-pose.pt` | Model weights |
| `CORS_ORIGINS` | API | Local/GitHub Pages origins | Comma-separated origins or `*` |
| `REACT_APP_API_URL` | Frontend | `http://localhost:60000` | API origin; `/` in EKS |
| `IMAGE_DIR` | Locust | `image` | Test image directory |
| `IMAGE_TAG` | ECR helper | `latest` | Image tag pushed by `push-ecr.sh` |

Terraform inputs are documented in `terraform/variables.tf` and `terraform/terraform.tfvars.example`.

## Troubleshooting

### Frontend cannot reach the API

```bash
curl http://localhost:60000/health
```

Check `REACT_APP_API_URL` and restart the React dev server after changing it. In EKS, confirm both services exist:

```bash
kubectl -n cloudpose get svc
```

### Pods fail to start

```bash
kubectl -n cloudpose get pods
kubectl -n cloudpose describe pod <pod-name>
kubectl -n cloudpose logs deployment/pose-estimator
```

Typical causes are missing ECR images, insufficient memory, ECR permissions, or a failed health probe. The recommended API allocation is at least 2 GiB.

### GitHub deployment cannot assume AWS role

- Confirm `AWS_GHA_ROLE_ARN` exactly matches `terraform output -raw github_actions_role_arn`
- Confirm the GitHub environment is named `eks`
- Confirm `github_repository = "imhero2k/CloudPose"` in Terraform
- Reapply Terraform after changing OIDC inputs

### Deployment cannot access Kubernetes

```bash
aws eks describe-cluster --name cloudpose --region ap-southeast-2
aws eks update-kubeconfig --name cloudpose --region ap-southeast-2
```

Ensure the OIDC role has an `aws_eks_access_entry` and `AmazonEKSEditPolicy` association for the `cloudpose` namespace.

## Project structure

```text
CloudPose/
├── app/                         FastAPI application and YOLO weights
├── docker/                      API/frontend Dockerfiles and nginx config
├── frontend/                    React application
├── k8s/                         Standalone Kubernetes manifests
├── load-testing/                Locust and experiment automation
├── samples/                     Local smoke-test image
├── scripts/                     ECR, pre-push, and Git hook helpers
├── terraform/                   EKS/ECR/VPC/IAM/Kubernetes IaC
├── tests/                       API, workflow, manifest, and IaC tests
├── .github/workflows/ci.yml     Pre-merge quality gate
└── .github/workflows/deploy-eks.yml
                                Merge-to-master EKS deployment
```

## Security notes

- Never commit AWS access keys, kubeconfigs, `.tfvars`, or Terraform state.
- CI uses short-lived GitHub OIDC credentials.
- Restrict CORS in production instead of leaving `CORS_ORIGINS=*`.
- Add HTTPS and a custom domain before exposing sensitive images.
- ECR image scanning is enabled by Terraform.

## License and attribution

CloudPose was developed for FIT5225 Cloud Computing. Pose inference uses [Ultralytics YOLOv8](https://docs.ultralytics.com/), subject to its licensing terms.
