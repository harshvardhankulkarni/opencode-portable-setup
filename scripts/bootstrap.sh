#!/usr/bin/env bash
# bootstrap.sh — curl|bash one-liner for Linux/macOS
# Usage: curl -fsSL https://raw.githubusercontent.com/<YOU>/opencode-portable-setup/main/scripts/bootstrap.sh | bash
set -e
REPO_URL="https://github.com/<YOU>/opencode-portable-setup.git"
DEST="$HOME/opencode-portable-setup"
if [ -n "${1:-}" ]; then REPO_URL="$1"; fi
echo "[bootstrap] cloning $REPO_URL -> $DEST"
if [ -d "$DEST/.git" ]; then
  echo "[bootstrap] exists, pulling"
  git -C "$DEST" pull --ff-only || git -C "$DEST" pull
else
  git clone "$REPO_URL" "$DEST"
fi
cd "$DEST"
chmod +x scripts/install.sh scripts/verify.sh scripts/lib/*.mjs 2>/dev/null || true
echo "[bootstrap] running installer"
bash scripts/install.sh "$@"
