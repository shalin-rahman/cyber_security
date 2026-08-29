#!/usr/bin/env bash
# XSS Lab — Setup Script
set -euo pipefail
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RESET='\033[0m'
echo "[Lab 02] XSS Attack Lab — Setup"
HOSTS_ENTRY="10.9.0.5   www.seed-server.com"
if grep -q "www.seed-server.com" /etc/hosts 2>/dev/null; then
  echo -e "${GREEN}✓ /etc/hosts already contains www.seed-server.com${RESET}"
else
  echo -e "${YELLOW}Adding hostname to /etc/hosts (requires sudo)...${RESET}"
  echo "$HOSTS_ENTRY" | sudo tee -a /etc/hosts
  echo -e "${GREEN}✓ Added: $HOSTS_ENTRY${RESET}"
fi
echo "Pulling images..."
docker compose pull
echo -e "${GREEN}✓ Setup complete. Run ./start.sh to launch the lab.${RESET}"
