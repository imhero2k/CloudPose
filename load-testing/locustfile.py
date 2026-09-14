import os
import json
import uuid
import base64
import random
import logging

from locust import HttpUser, task, between

# ─── Configuration ─────────────────────────────────────────────────────────────
IMAGE_DIR = os.getenv("IMAGE_DIR", "image")

logging.basicConfig(
    format="%(asctime)s %(levelname)s %(message)s",
    level=logging.INFO
)
logger = logging.getLogger(__name__)

encoded_images = []
if os.path.isdir(IMAGE_DIR):
    for entry in sorted(os.listdir(IMAGE_DIR)):
        path = os.path.join(IMAGE_DIR, entry)
        if os.path.isdir(path):
            logger.debug("Skipping directory %s", path)
            continue
        try:
            with open(path, "rb") as img_file:
                encoded_images.append(base64.b64encode(img_file.read()).decode("utf-8"))
        except OSError as exc:
            logger.warning("Failed to load image %s: %s", path, exc)
else:
    logger.error("Image directory `%s` does not exist", IMAGE_DIR)

if not encoded_images:
    logger.error("No images loaded from `%s`; check that it exists and contains files.", IMAGE_DIR)
else:
    logger.info("Loaded %s images from `%s`", len(encoded_images), IMAGE_DIR)

# ─── Locust User Class ─────────────────────────────────────────────────────────
class APIUser(HttpUser):
    wait_time = between(1, 3)

    @task(1)
    def upload_pose(self):
        if not encoded_images:
            return
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
        if not encoded_images:
            return
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
