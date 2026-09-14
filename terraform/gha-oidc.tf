data "tls_certificate" "github" {
  count = var.enable_github_actions_deploy && var.github_oidc_provider_arn == null ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.enable_github_actions_deploy && var.github_oidc_provider_arn == null ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github[0].certificates[0].sha1_fingerprint]
}

locals {
  github_oidc_arn = var.enable_github_actions_deploy ? (
    var.github_oidc_provider_arn != null ? var.github_oidc_provider_arn : aws_iam_openid_connect_provider.github[0].arn
  ) : null
}

data "aws_iam_policy_document" "gha_assume" {
  count = var.enable_github_actions_deploy ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.github_oidc_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_repository}:ref:refs/heads/master",
        "repo:${var.github_repository}:environment:eks",
      ]
    }
  }
}

resource "aws_iam_role" "gha_deploy" {
  count              = var.enable_github_actions_deploy ? 1 : 0
  name               = "${local.name}-github-actions-eks"
  assume_role_policy = data.aws_iam_policy_document.gha_assume[0].json
}

data "aws_iam_policy_document" "gha_deploy" {
  count = var.enable_github_actions_deploy ? 1 : 0

  statement {
    sid = "EcrAuth"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement {
    sid = "EcrPush"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:DescribeRepositories",
    ]
    resources = [
      aws_ecr_repository.api.arn,
      aws_ecr_repository.frontend.arn,
    ]
  }

  statement {
    sid = "EksKubeconfig"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
    ]
    resources = [aws_eks_cluster.this.arn]
  }
}

resource "aws_iam_role_policy" "gha_deploy" {
  count  = var.enable_github_actions_deploy ? 1 : 0
  name   = "${local.name}-github-actions-eks"
  role   = aws_iam_role.gha_deploy[0].id
  policy = data.aws_iam_policy_document.gha_deploy[0].json
}

resource "aws_eks_access_entry" "gha" {
  count         = var.enable_github_actions_deploy ? 1 : 0
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.gha_deploy[0].arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "gha" {
  count         = var.enable_github_actions_deploy ? 1 : 0
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
  principal_arn = aws_iam_role.gha_deploy[0].arn

  access_scope {
    type       = "namespace"
    namespaces = [var.namespace]
  }

  depends_on = [aws_eks_access_entry.gha]
}
