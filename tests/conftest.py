import base64
import sys
from pathlib import Path
from types import SimpleNamespace

import cv2
import numpy as np
import pytest
from fastapi.testclient import TestClient

ROOT = Path(__file__).resolve().parents[1]
APP_DIR = ROOT / "app"
if str(APP_DIR) not in sys.path:
    sys.path.insert(0, str(APP_DIR))

import app as cloudpose  # noqa: E402


class FakeBox:
    def __init__(self, x=100.0, y=200.0, w=50.0, h=80.0, conf=0.91):
        self.xywh = np.array([[x, y, w, h]], dtype=float)
        self.conf = np.array([conf], dtype=float)


class FakeKeypoints:
    def __init__(self):
        self.xy = np.array([[[10.0, 20.0], [30.0, 40.0], [50.0, 60.0]]], dtype=float)
        self.conf = np.array([[0.9, 0.8, 0.2]], dtype=float)


_UNSET = object()


class FakeResult:
    def __init__(self, boxes=_UNSET, keypoints=_UNSET):
        self.boxes = [FakeBox()] if boxes is _UNSET else boxes
        self.keypoints = [FakeKeypoints()] if keypoints is _UNSET else keypoints


class FakeModel:
    def __init__(self, result=None, error=None):
        self.result = result or FakeResult()
        self.error = error
        self.calls = []

    def __call__(self, img):
        self.calls.append(img)
        if self.error:
            raise self.error
        return [self.result]


def make_jpeg_b64(width=32, height=24, color=(0, 128, 255)):
    img = np.zeros((height, width, 3), dtype=np.uint8)
    img[:] = color
    ok, buffer = cv2.imencode(".jpg", img)
    assert ok
    return base64.b64encode(buffer).decode("utf-8")


@pytest.fixture
def fake_model(monkeypatch):
    model = FakeModel()
    monkeypatch.setattr(cloudpose, "get_model", lambda: model)
    return model


@pytest.fixture
def client(fake_model):
    return TestClient(cloudpose.app), fake_model
