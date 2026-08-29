#!/usr/bin/env bash
# Shellshock Lab — Setup Script
set -euo pipefail
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RESET='\033[0m'
echo "[Lab 05] Shellshock Vulnerability Lab — Setup"

HOSTS_ENTRY="10.9.0.80   www.seedlab-shellshock.com"
if grep -q "www.seedlab-shellshock.com" /etc/hosts 2>/dev/null; then
  echo -e "${GREEN}✓ /etc/hosts already contains www.seedlab-shellshock.com${RESET}"
else
  echo -e "${YELLOW}Adding hostname to /etc/hosts (requires sudo)...${RESET}"
  echo "$HOSTS_ENTRY" | sudo tee -a /etc/hosts
fi

docker compose pull
echo -e "${GREEN}✓ Setup complete. Run ./start.sh to launch the lab.${RESET}"
