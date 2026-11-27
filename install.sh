#!/bin/bash
set -euo pipefail
ZIP_URL="https://github.com/ajisetio8765-blip/installhome/releases/latest/download/dalangstore-glass-theme.zip"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo -e "\x1b[38;5;45m[Dalang Store] Mengunduh paket v1.2.4...\x1b[0m"
command -v unzip >/dev/null 2>&1 || (apt-get update -qq && apt-get install -y -qq unzip)
curl -fsSL "$ZIP_URL" -o "$TMP_DIR/theme.zip"
unzip -q "$TMP_DIR/theme.zip" -d "$TMP_DIR/pkg"
chmod +x "$TMP_DIR/pkg/install.sh"
bash "$TMP_DIR/pkg/install.sh" "${1:-menu}"
