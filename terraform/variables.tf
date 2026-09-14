variable "aws_region" {
  type        = string
  description = "AWS region for EKS, ECR, and the load balancer."
  default     = "ap-southeast-2"
}

variable "project_name" {
  type        = string
  description = "Name prefix for AWS and Kubernetes resources."
  default     = "cloudpose"
}

variable "cluster_version" {
  type        = string
  description = "EKS Kubernetes version."
  default     = "1.31"
}

variable "node_instance_type" {
  type        = string
  description = "EC2 instance type for the managed node group. t3.large (8 GiB) is the practical minimum for YOLOv8 + PyTorch."
  default     = "t3.large"
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "vpc_cidr" {
  type    = string
  default = "10.50.0.0/16"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace for CloudPose."
  default     = "cloudpose"
}

variable "api_replicas" {
  type    = number
  default = 1
}

variable "api_cpu" {
  type    = string
  default = "1"
}

variable "api_memory" {
  type    = string
  default = "2Gi"
}

variable "image_tag" {
  type        = string
  description = "ECR image tag for the API and frontend."
  default     = "latest"
}

variable "cors_origins" {
  type        = string
  description = "Value for the API CORS_ORIGINS env var."
  default     = "*"
}

variable "enable_github_actions_deploy" {
  type        = bool
  description = "Create the GitHub Actions OIDC IAM role and EKS access entry used by deploy-eks.yml."
  default     = true
}

variable "github_repository" {
  type        = string
  description = "GitHub org/repo allowed to assume the deploy role (e.g. imhero2k/CloudPose)."
  default     = "imhero2k/CloudPose"
}

variable "github_oidc_provider_arn" {
  type        = string
  description = "Existing GitHub OIDC provider ARN. Leave null to create one."
  default     = null
}
