from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TF = ROOT / "terraform"


def test_terraform_layout():
    for name in (
        "versions.tf",
        "variables.tf",
        "vpc.tf",
        "iam.tf",
        "eks.tf",
        "ecr.tf",
        "k8s.tf",
        "outputs.tf",
        "README.md",
    ):
        assert (TF / name).is_file(), name


def test_eks_and_workloads_are_declared():
    eks = (TF / "eks.tf").read_text()
    k8s = (TF / "k8s.tf").read_text()
    gha = (TF / "gha-oidc.tf").read_text()
    assert 'resource "aws_eks_cluster" "this"' in eks
    assert 'resource "aws_eks_node_group" "this"' in eks
    assert "pose-estimator" in k8s
    assert "LoadBalancer" in k8s
    assert "/health" in k8s
    assert "github-actions" in gha
    assert "AmazonEKSEditPolicy" in gha


def test_deploy_eks_workflow_covers_build_and_rollout():
    workflow = (ROOT / ".github" / "workflows" / "deploy-eks.yml").read_text()
    assert "push:" in workflow
    assert "branches: [master]" in workflow
    assert "amazon-ecr-login" in workflow
    assert "docker/Dockerfile.frontend" in workflow
    assert "kubectl -n \"$NS\" set image" in workflow
    assert "rollout status" in workflow
    assert "AWS_GHA_ROLE_ARN" in workflow


def test_pre_merge_workflow_covers_required_gates():
    workflow = (ROOT / ".github" / "workflows" / "ci.yml").read_text()
    assert "pull_request:" in workflow
    assert "Pre-merge gate" in workflow
    assert "pytest -q" in workflow
    assert "npm run build" in workflow
    assert "terraform validate" in workflow
    assert "hadolint" in workflow
    assert "actionlint" in workflow
    assert "docker/Dockerfile.frontend" in workflow
    assert (ROOT / "scripts" / "pre-push.sh").is_file()
