# CloudPose on Amazon EKS

Terraform in this directory creates:

- A VPC with two public subnets
- An EKS cluster and managed node group
- ECR repositories for the API and frontend
- Kubernetes deployments for YOLOv8 pose estimation and the React UI
- An internet-facing Network Load Balancer in front of nginx (UI + `/api` proxy)

The API needs more than the assignment’s 512 MiB pod limit. Defaults are **1 vCPU / 2 GiB** on **t3.large** nodes.

## Prerequisites

- Terraform >= 1.5
- AWS CLI v2 with credentials that can create VPC, EKS, IAM, ECR, and ELB
- Docker (to build and push images)
- `kubectl` (optional, for debugging)

```bash
aws sts get-caller-identity
cp terraform.tfvars.example terraform.tfvars   # edit region / sizes
```

## Apply

Kubernetes resources need a live cluster, so apply in two waves:

```bash
cd terraform

terraform init

# 1. Cluster + ECR only
terraform apply \
  -target=aws_eks_cluster.this \
  -target=aws_eks_node_group.this \
  -target=aws_ecr_repository.api \
  -target=aws_ecr_repository.frontend

# 2. Build and push images
../scripts/push-ecr.sh

# 3. Deploy the app (namespace, API, frontend, NLB)
terraform apply
```

```bash
aws eks update-kubeconfig --region "$(terraform output -raw region)" --name "$(terraform output -raw cluster_name)"
kubectl -n cloudpose get pods,svc
terraform output load_balancer_hostname
```

Open `http://<load_balancer_hostname>/`. The UI posts to `/api/pose` on the same host.

## Destroy

```bash
terraform destroy
```

ECR `force_delete` is on so destroy can remove repositories that still contain images.

## Cost

This stack is not free: EKS control plane, 1–2 × `t3.large`, a NAT-less public node group, and an NLB. Tear it down when you are done.
