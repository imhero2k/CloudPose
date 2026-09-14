#!/usr/bin/env bash
# Fast local gate: run this before git push (also installed as .git/hooks/pre-push).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Python compile"
python3 -m py_compile app/app.py load-testing/locustfile.py load-testing/Automation.py

echo "==> pytest"
if [[ -x "$ROOT/.venv/bin/pytest" ]]; then
  "$ROOT/.venv/bin/pytest" -q
elif command -v pytest >/dev/null; then
  pytest -q
else
  echo "pytest not found; pip install -r requirements-dev.txt" >&2
  exit 1
fi

if [[ -d frontend/node_modules ]]; then
  echo "==> frontend tests"
  (
    cd frontend
    CI=true npm test -- --watchAll=false
  )
else
  echo "skip frontend tests (frontend/node_modules missing; run npm ci in frontend/)"
fi

if command -v terraform >/dev/null; then
  echo "==> terraform fmt/validate"
  terraform -chdir=terraform fmt -check -recursive
  terraform -chdir=terraform init -backend=false -input=false >/dev/null
  terraform -chdir=terraform validate
else
  echo "skip terraform (terraform CLI not on PATH)"
fi

if command -v docker >/dev/null && docker info >/dev/null 2>&1; then
  echo "==> docker compose config"
  docker compose -f docker-compose.yml config --quiet
else
  echo "skip docker compose (docker not available)"
fi

echo "pre-push checks passed"
