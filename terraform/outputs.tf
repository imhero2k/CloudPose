output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "region" {
  value = var.aws_region
}

output "ecr_api_url" {
  value = aws_ecr_repository.api.repository_url
}

output "ecr_frontend_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.this.name}"
}

output "load_balancer_hostname" {
  description = "Public NLB for the CloudPose UI (proxies /api to the pose service)."
  value       = try(kubernetes_service_v1.frontend.status[0].load_balancer[0].ingress[0].hostname, null)
}
