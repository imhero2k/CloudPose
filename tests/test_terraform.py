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
    assert 'resource "aws_eks_cluster" "this"' in eks
    assert 'resource "aws_eks_node_group" "this"' in eks
    assert "pose-estimator" in k8s
    assert "LoadBalancer" in k8s
    assert "/health" in k8s
