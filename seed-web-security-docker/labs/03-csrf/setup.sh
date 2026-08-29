#!/usr/bin/env bash
# CSRF Lab — Setup Script
set -euo pipefail
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RESET='\033[0m'

echo "[Lab 03] CSRF Attack Lab — Setup"

# Verify /etc/hosts entries
for host in "10.9.0.5    www.seed-server.com" "10.9.0.105  www.attacker32.com"; do
  domain="$(echo "$host" | awk '{print $2}')"
  if grep -q "$domain" /etc/hosts 2>/dev/null; then
    echo -e "${GREEN}✓ /etc/hosts contains $domain${RESET}"
  else
    echo -e "${YELLOW}Adding $domain to /etc/hosts...${RESET}"
    echo "$host" | sudo tee -a /etc/hosts
  fi
done

echo "Pulling lab images..."
docker compose pull
echo -e "${GREEN}✓ Setup complete. Run ./start.sh to launch the lab.${RESET}"
