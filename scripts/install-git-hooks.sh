#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK_DIR="$ROOT/.git/hooks"
mkdir -p "$HOOK_DIR"
cat > "$HOOK_DIR/pre-push" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
exec "$ROOT/scripts/pre-push.sh"
EOF
chmod +x "$HOOK_DIR/pre-push" "$ROOT/scripts/pre-push.sh"
echo "Installed $HOOK_DIR/pre-push -> scripts/pre-push.sh"
