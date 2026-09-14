#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="$ROOT/terraform"

if [[ ! -d "$TF_DIR" ]]; then
  echo "terraform/ not found" >&2
  exit 1
fi

cd "$TF_DIR"
REGION="$(terraform output -raw region)"
API_URL="$(terraform output -raw ecr_api_url)"
FE_URL="$(terraform output -raw ecr_frontend_url)"
TAG="${IMAGE_TAG:-latest}"
REGISTRY="${API_URL%%/*}"

aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$REGISTRY"

docker build -f "$ROOT/docker/Dockerfile" -t "${API_URL}:${TAG}" "$ROOT"
docker build -f "$ROOT/docker/Dockerfile.frontend" -t "${FE_URL}:${TAG}" "$ROOT"
docker push "${API_URL}:${TAG}"
docker push "${FE_URL}:${TAG}"

echo "Pushed ${API_URL}:${TAG}"
echo "Pushed ${FE_URL}:${TAG}"
