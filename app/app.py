import base64
import logging
import os
import time
import uuid
from typing import Optional

import cv2
import numpy as np
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from ultralytics import YOLO

APP_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.getenv("YOLO_MODEL_PATH", os.path.join(APP_DIR, "yolov8n-pose.pt"))
PORT = int(os.getenv("PORT", "60000"))

DEFAULT_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:3001",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:3001",
    "https://imhero2k.github.io",
    "https://imhero2k.github.io/CloudPose",
]

cors_origins_env = os.getenv("CORS_ORIGINS", "").strip()
if cors_origins_env == "*":
    allow_origins = ["*"]
    allow_credentials = False
elif cors_origins_env:
    allow_origins = [origin.strip() for origin in cors_origins_env.split(",") if origin.strip()]
    allow_credentials = True
else:
    allow_origins = DEFAULT_ORIGINS
    allow_credentials = True

app = FastAPI(
    title="CloudPose",
    description="YOLOv8 pose estimation API for FIT5225 Assignment 1",
    version="1.0.0",
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=allow_origins,
    allow_credentials=allow_credentials,
    allow_methods=["*"],
    allow_headers=["*"],
)

logger = logging.getLogger("uvicorn")
model = YOLO(MODEL_PATH)


class PoseRequest(BaseModel):
    image: str
    file_name: str = "image.jpg"
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))


def decode_image(image_b64: str) -> Optional[np.ndarray]:
    img_b64 = image_b64.split("base64,", 1)[1] if "base64," in image_b64 else image_b64
    try:
        img_bytes = base64.b64decode(img_b64, validate=False)
    except Exception:
        return None
    nparr = np.frombuffer(img_bytes, np.uint8)
    return cv2.imdecode(nparr, cv2.IMREAD_COLOR)


def extract_detections(result):
    boxes = []
    keypoints = []
    if result.boxes is None or result.keypoints is None:
        return boxes, keypoints

    for box, kp in zip(result.boxes, result.keypoints):
        boxes.append(
            {
                "x": float(box.xywh[0][0]),
                "y": float(box.xywh[0][1]),
                "width": float(box.xywh[0][2]),
                "height": float(box.xywh[0][3]),
                "probability": float(box.conf[0]),
            }
        )
        xy = kp.xy[0].tolist()
        confs = kp.conf[0].tolist() if kp.conf is not None else [1.0] * len(xy)
        keypoints.append(
            [[float(x), float(y), float(conf)] for (x, y), conf in zip(xy, confs)]
        )
    return boxes, keypoints


def annotate_image(img, result):
    annotated = img.copy()
    if result.boxes is None or result.keypoints is None:
        return annotated

    for box, kp in zip(result.boxes, result.keypoints):
        x, y, w, h = box.xywh[0]
        x1, y1 = int(x - w / 2), int(y - h / 2)
        x2, y2 = int(x + w / 2), int(y + h / 2)
        cv2.rectangle(annotated, (x1, y1), (x2, y2), (0, 255, 0), 2)
        xy = kp.xy[0].tolist()
        confs = kp.conf[0].tolist() if kp.conf is not None else [1.0] * len(xy)
        for (px, py), conf in zip(xy, confs):
            if conf > 0.3:
                cv2.circle(annotated, (int(px), int(py)), 3, (0, 0, 255), -1)
    return annotated


@app.get("/")
@app.get("/health")
async def health():
    return {
        "status": "ok",
        "service": "cloudpose",
        "model": os.path.basename(MODEL_PATH),
        "docs": "/docs",
        "endpoints": ["/api/pose", "/api/pose/annotated"],
    }


@app.post("/api/pose")
async def pose_estimation(request: PoseRequest):
    start_time = time.time()
    try:
        img = decode_image(request.image)
        if img is None:
            return JSONResponse(
                {"id": request.id, "error": "Invalid image payload"},
                status_code=400,
            )

        result = model(img)[0]
        boxes, keypoints = extract_detections(result)
        processing_time = time.time() - start_time
        return JSONResponse(
            {
                "id": request.id,
                "count": len(boxes),
                "boxes": boxes,
                "keypoints": keypoints,
                "processing_time": f"{processing_time:.2f}s",
                "file_name": request.file_name,
            }
        )
    except Exception as e:
        logger.error("Error processing image %s: %s", request.file_name, e)
        return JSONResponse(
            {"id": request.id, "error": "Image processing failed"},
            status_code=500,
        )


@app.post("/api/pose/annotated")
async def annotated_pose(request: PoseRequest):
    try:
        img = decode_image(request.image)
        if img is None:
            return JSONResponse(
                {"id": request.id, "error": "Invalid image payload"},
                status_code=400,
            )

        result = model(img)[0]
        annotated = annotate_image(img, result)
        _, buffer = cv2.imencode(".jpg", annotated)
        img_base64 = base64.b64encode(buffer).decode("utf-8")
        return JSONResponse(
            {
                "id": request.id,
                "image": img_base64,
                "file_name": request.file_name,
                "message": "Pose annotated successfully",
            }
        )
    except Exception as e:
        logger.error("Error annotating image %s: %s", request.file_name, e)
        return JSONResponse(
            {"id": request.id, "error": "Annotation failed"},
            status_code=500,
        )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=PORT)
