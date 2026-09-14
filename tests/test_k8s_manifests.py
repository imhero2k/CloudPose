from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]


def test_deployment_container_port_matches_dockerfile():
    deployment = yaml.safe_load((ROOT / "k8s" / "deployment.yaml").read_text())
    container = deployment["spec"]["template"]["spec"]["containers"][0]
    assert container["ports"][0]["containerPort"] == 80
    assert container["env"][0]["name"] == "PORT"
    assert container["env"][0]["value"] == "80"
    dockerfile = (ROOT / "docker" / "Dockerfile").read_text()
    assert "EXPOSE 80" in dockerfile


def test_service_targets_port_80():
    service = yaml.safe_load((ROOT / "k8s" / "service.yaml").read_text())
    port = service["spec"]["ports"][0]
    assert port["port"] == 80
    assert port["targetPort"] == 80
    assert port["nodePort"] == 30080


def test_ingress_points_at_estimator_service():
    ingress = yaml.safe_load((ROOT / "k8s" / "ingress.yaml").read_text())
    backends = [
        path["backend"]["service"]["name"]
        for rule in ingress["spec"]["rules"]
        for path in rule["http"]["paths"]
    ]
    assert backends
    assert all(name == "pose-estimator-service" for name in backends)
