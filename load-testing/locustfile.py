import os
import json
import uuid
import base64
import random
import logging

from locust import HttpUser, task, between

# ─── Configuration ─────────────────────────────────────────────────────────────
IMAGE_DIR = os.getenv("IMAGE_DIR", "image")

# Optional: configure logging
logging.basicConfig(
    format="%(asctime)s %(levelname)s %(message)s",
    level=logging.INFO
)
logger = logging.getLogger(__name__)

# ─── Preload Images ────────────────────────────────────────────────────────────
encoded_images = []
for entry in sorted(os.listdir(IMAGE_DIR)):
    path = os.path.join(IMAGE_DIR, entry)
    # skip directories
    if os.path.isdir(path):
        logger.debug(f"Skipping directory {path}")
        continue

    try:
        with open(path, "rb") as img_file:
            encoded = base64.b64encode(img_file.read()).decode("utf-8")
            encoded_images.append(encoded)
    except Exception as e:
        logger.warning(f"Failed to load image {path}: {e}")

if not encoded_images:
    logger.error(f"No images loaded from `{IMAGE_DIR}`; check that it exists and contains files.")
else:
    logger.info(f"Loaded {len(encoded_images)} images from `{IMAGE_DIR}`")

# ─── Locust User Class ─────────────────────────────────────────────────────────
class APIUser(HttpUser):
    wait_time = between(1, 3)

    @task(1)
    def upload_pose(self):
        payload = {
            "image": random.choice(encoded_images),
            "file_name": f"img_{random.randint(1,128)}.jpg",
            "id": str(uuid.uuid4())
        }
        headers = {"Content-Type": "application/json"}

        with self.client.post("/api/pose", json=payload, headers=headers, catch_response=True) as response:
            if response.status_code != 200:
                logger.error(f"[pose] {response.status_code} {response.text}")
                response.failure(f"Unexpected status code: {response.status_code}")
            else:
                try:
                    _ = response.json()
                except Exception as e:
                    logger.warning(f"[pose] Failed to parse JSON: {e}")

    @task(1)
    def upload_annotated_pose(self):
        payload = {
            "image": random.choice(encoded_images),
            "file_name": f"img_{random.randint(1,128)}.jpg",
            "id": str(uuid.uuid4())
        }
        headers = {"Content-Type": "application/json"}

        with self.client.post("/api/pose/annotated", json=payload, headers=headers, catch_response=True) as response:
            if response.status_code != 200:
                logger.error(f"[pose/annotated] {response.status_code} {response.text}")
                response.failure(f"Unexpected status code: {response.status_code}")
            else:
                try:
                    _ = response.json()
                except Exception as e:
                    logger.warning(f"[pose/annotated] Failed to parse JSON: {e}")
