from fastapi import FastAPI
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import cv2
import numpy as np
import logging
from ultralytics import YOLO
import uuid
import time
import base64
from pydantic import BaseModel

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000", 
        "http://localhost:3001", 
        "http://127.0.0.1:3000", 
        "http://127.0.0.1:3001",
        "https://imhero2k.github.io",
        "https://imhero2k.github.io/CloudPose"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
model = YOLO('yolov8n-pose.pt')
logger = logging.getLogger("uvicorn")

# Pydantic model for base64 request
class PoseRequest(BaseModel):
    image: str  # Base64 encoded image
    file_name: str = "image.jpg"
    id: str = str(uuid.uuid4())

@app.post("/api/pose")
async def pose_estimation(request: PoseRequest):
    start_time = time.time()
    
    try:
        # Handle base64 with optional data URL prefix
        img_b64 = request.image
        if 'base64,' in img_b64:
            img_b64 = img_b64.split('base64,', 1)[1]
            
        img_bytes = base64.b64decode(img_b64)
        nparr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        # Rest of the original code remains the same
        results = model(img)
        result = results[0]
        
        boxes = []
        keypoints = []
        
        if result.keypoints is not None:
            for box, kp in zip(result.boxes, result.keypoints):
                boxes.append({
                    "x": float(box.xywh[0][0]),
                    "y": float(box.xywh[0][1]),
                    "width": float(box.xywh[0][2]),
                    "height": float(box.xywh[0][3]),
                    "probability": float(box.conf[0])
                })
                
                keypoints.append([
                    [float(x), float(y), float(conf)] 
                    for (x, y), conf in zip(kp.xy[0].tolist(), kp.conf[0].tolist())
                ])
        
        processing_time = time.time() - start_time
        
        return JSONResponse({
            "id": request.id,
            "count": len(boxes),
            "boxes": boxes,
            "keypoints": keypoints,
            "processing_time": f"{processing_time:.2f}s",
            "file_name": request.file_name
        })
        
    except Exception as e:
        logger.error(f"Error processing image {request.file_name}: {str(e)}")
        return JSONResponse(
            {"id": request.id, "error": "Image processing failed"},
            status_code=500
        )

@app.post("/api/pose/annotated")
async def annotated_pose(request: PoseRequest):
    try:
        # Base64 handling same as above
        img_b64 = request.image
        if 'base64,' in img_b64:
            img_b64 = img_b64.split('base64,', 1)[1]
            
        img_bytes = base64.b64decode(img_b64)
        nparr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        # Rest of original code remains the same
        results = model(img)
        result = results[0]

        if result.keypoints is not None:
            for box, kp in zip(result.boxes, result.keypoints):
                x, y, w, h = box.xywh[0]
                x1 = int(x - w / 2)
                y1 = int(y - h / 2)
                x2 = int(x + w / 2)
                y2 = int(y + h / 2)
                cv2.rectangle(img, (x1, y1), (x2, y2), (0, 255, 0), 2)

                for (px, py), conf in zip(kp.xy[0].tolist(), kp.conf[0].tolist()):
                    if conf > 0.3:
                        cv2.circle(img, (int(px), int(py)), 3, (0, 0, 255), -1)

        _, buffer = cv2.imencode('.jpg', img)
        img_base64 = base64.b64encode(buffer).decode("utf-8")

        return JSONResponse({
            "id": request.id,
            "image": img_base64,
            "file_name": request.file_name,
            "message": "Pose annotated successfully"
        })

    except Exception as e:
        logger.error(f"Error annotating image {request.file_name}: {str(e)}")
        return JSONResponse(
            {"id": request.id, "error": "Annotation failed"},
            status_code=500
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=60000)
