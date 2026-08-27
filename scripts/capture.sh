#!/usr/bin/env bash
# capture.sh — re-snapshot the live workstation into the repo
set -e
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "[capture] repo: $REPO_DIR"
echo "[capture] running capture-full.mjs (opencode+claude+codex+omniroute+freellmapi+gemini/qwen)..."
node "$REPO_DIR/scripts/lib/capture-full.mjs"
echo ""
echo "[capture] pruning gstack binaries (if re-added)"
rm -rf "$REPO_DIR/claude/skills/gstack/make-pdf/dist" "$REPO_DIR/claude/skills/gstack/design/dist" "$REPO_DIR/claude/skills/gstack/browse/dist" "$REPO_DIR/claude/skills/gstack/bin" "$REPO_DIR/claude/skills/gstack/lib/diagram-render/dist" 2>/dev/null || true
rm -f "$REPO_DIR/claude/skills/gstack/scripts/app/icon.icns" "$REPO_DIR/claude/skills/gstack/browse/test/fixtures/security-bench-haiku-responses.json" 2>/dev/null || true
find "$REPO_DIR/claude" -type d -name ".git" -exec rm -rf {} \; 2>/dev/null || true
find "$REPO_DIR" -type d -name "node_modules" -not -path "*/.agents/*" 2>/dev/null | head
echo "[capture] refreshing INVENTORY counts..."
# quick counts
op_a=$(ls -1 "$REPO_DIR/agents" 2>/dev/null | wc -l | tr -d ' ')
cl_a=$(ls -1 "$REPO_DIR/claude/agents" 2>/dev/null | wc -l | tr -d ' ')
cl_s=$(ls -1 "$REPO_DIR/claude/skills" 2>/dev/null | wc -l | tr -d ' ')
ext=$(ls -1 "$REPO_DIR/skills/external-full" 2>/dev/null | wc -l | tr -d ' ')
echo "  opencode agents: $op_a  claude agents: $cl_a  claude skills: $cl_s  external: $ext"
du -sh "$REPO_DIR" 2>&1 | head -n1
echo ""
echo "[capture] done — review: git status, then: git add -A && git commit -m 'chore: snapshot \$(date -I)' && git push"
echo "  verify before push: ./scripts/verify.sh --verbose  (or verify.ps1 on Windows)"
