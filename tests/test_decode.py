import base64

import numpy as np

import app as cloudpose
from tests.conftest import FakeBox, FakeKeypoints, FakeResult, make_jpeg_b64


def test_decode_image_roundtrip():
    encoded = make_jpeg_b64(width=16, height=12, color=(10, 20, 30))
    img = cloudpose.decode_image(encoded)
    assert img is not None
    assert img.shape[0] == 12
    assert img.shape[1] == 16
    assert img.dtype == np.uint8


def test_decode_image_data_url():
    encoded = "data:image/jpeg;base64," + make_jpeg_b64()
    assert cloudpose.decode_image(encoded) is not None


def test_decode_image_garbage():
    assert cloudpose.decode_image(base64.b64encode(b"xyz").decode()) is None


def test_extract_detections_none():
    boxes, kps = cloudpose.extract_detections(FakeResult(boxes=None, keypoints=None))
    assert boxes == []
    assert kps == []


def test_extract_detections_fills_missing_confidence():
    kp = FakeKeypoints()
    kp.conf = None
    boxes, kps = cloudpose.extract_detections(FakeResult(boxes=[FakeBox()], keypoints=[kp]))
    assert len(boxes) == 1
    assert all(conf == 1.0 for _, _, conf in kps[0])
