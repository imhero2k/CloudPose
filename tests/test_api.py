import base64

from tests.conftest import FakeModel, FakeResult, make_jpeg_b64


def test_health(client):
    http, _ = client
    response = http.get("/health")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "ok"
    assert body["service"] == "cloudpose"
    assert "/api/pose" in body["endpoints"]


def test_root_health_alias(client):
    http, _ = client
    response = http.get("/")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_pose_returns_mocked_keypoints(client):
    http, model = client
    response = http.post(
        "/api/pose",
        json={"image": make_jpeg_b64(), "id": "req-1", "file_name": "pose.jpg"},
    )
    assert response.status_code == 200
    body = response.json()
    assert body["id"] == "req-1"
    assert body["file_name"] == "pose.jpg"
    assert body["count"] == 1
    assert body["boxes"][0]["probability"] == 0.91
    assert len(body["keypoints"][0]) == 3
    assert len(model.calls) == 1
    assert "processing_time" in body


def test_pose_accepts_data_url_prefix(client):
    http, _ = client
    payload = "data:image/jpeg;base64," + make_jpeg_b64()
    response = http.post("/api/pose", json={"image": payload, "id": "data-url"})
    assert response.status_code == 200
    assert response.json()["count"] == 1


def test_pose_rejects_non_image_payload(client):
    http, model = client
    junk = base64.b64encode(b"not-an-image").decode("utf-8")
    response = http.post("/api/pose", json={"image": junk, "id": "bad"})
    assert response.status_code == 400
    assert response.json()["error"] == "Invalid image payload"
    assert model.calls == []


def test_pose_missing_image_is_unprocessable(client):
    http, _ = client
    response = http.post("/api/pose", json={"file_name": "x.jpg"})
    assert response.status_code == 422


def test_pose_model_failure_returns_500(monkeypatch):
    import app as cloudpose
    from fastapi.testclient import TestClient

    monkeypatch.setattr(
        cloudpose,
        "get_model",
        lambda: FakeModel(error=RuntimeError("boom")),
    )
    http = TestClient(cloudpose.app)
    response = http.post(
        "/api/pose",
        json={"image": make_jpeg_b64(), "id": "fail"},
    )
    assert response.status_code == 500
    assert response.json()["error"] == "Image processing failed"


def test_annotated_returns_jpeg(client):
    http, _ = client
    response = http.post(
        "/api/pose/annotated",
        json={"image": make_jpeg_b64(), "id": "ann-1", "file_name": "ann.jpg"},
    )
    assert response.status_code == 200
    body = response.json()
    assert body["message"] == "Pose annotated successfully"
    raw = base64.b64decode(body["image"])
    assert raw[:2] == b"\xff\xd8"
    assert body["file_name"] == "ann.jpg"


def test_annotated_empty_detections(monkeypatch):
    import app as cloudpose
    from fastapi.testclient import TestClient

    monkeypatch.setattr(
        cloudpose,
        "get_model",
        lambda: FakeModel(result=FakeResult(boxes=None, keypoints=None)),
    )
    http = TestClient(cloudpose.app)
    response = http.post(
        "/api/pose/annotated",
        json={"image": make_jpeg_b64(), "id": "empty"},
    )
    assert response.status_code == 200
    assert response.json()["image"]


def test_annotated_rejects_invalid_image(client):
    http, _ = client
    response = http.post(
        "/api/pose/annotated",
        json={"image": "", "id": "empty-img"},
    )
    assert response.status_code == 400
    assert response.json()["error"] == "Invalid image payload"


def test_docs_and_openapi(client):
    http, _ = client
    assert http.get("/docs").status_code == 200
    spec = http.get("/openapi.json")
    assert spec.status_code == 200
    paths = spec.json()["paths"]
    assert "/api/pose" in paths
    assert "/api/pose/annotated" in paths
    assert "/health" in paths


def test_pose_rejects_malformed_json(client):
    http, _ = client
    response = http.post(
        "/api/pose",
        content=b"not-json",
        headers={"Content-Type": "application/json"},
    )
    assert response.status_code == 422
