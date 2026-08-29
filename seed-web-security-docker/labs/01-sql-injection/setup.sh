#!/usr/bin/env bash
# SQL Injection Lab — Setup Script
# Downloads official SEED lab files and configures /etc/hosts
set -euo pipefail
BOLD='\033[1m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RESET='\033[0m'

echo -e "${BOLD}[Lab 01] SQL Injection — Setup${RESET}"
echo ""

# Check Docker
if ! command -v docker &>/dev/null; then
  echo "ERROR: Docker not found. Run scripts/check-environment.sh first." && exit 1
fi

# /etc/hosts entry
HOSTS_ENTRY="10.9.0.5   www.seed-server.com"
if grep -q "www.seed-server.com" /etc/hosts 2>/dev/null; then
  echo -e "${GREEN}✓ /etc/hosts already contains www.seed-server.com${RESET}"
else
  echo -e "${YELLOW}Adding hostname to /etc/hosts (requires sudo)...${RESET}"
  echo "$HOSTS_ENTRY" | sudo tee -a /etc/hosts
  echo -e "${GREEN}✓ Added: $HOSTS_ENTRY${RESET}"
fi

echo ""
echo "Pulling lab images (this may take several minutes on first run)..."
docker compose pull
echo -e "${GREEN}✓ Setup complete. Run ./start.sh to launch the lab.${RESET}"
