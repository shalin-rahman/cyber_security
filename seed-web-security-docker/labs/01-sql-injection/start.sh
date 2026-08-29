#!/usr/bin/env bash
# SQL Injection Lab — Start Script
set -euo pipefail
GREEN='\033[0;32m'; BOLD='\033[1m'; RESET='\033[0m'
echo -e "${BOLD}[Lab 01] SQL Injection — Starting...${RESET}"
docker compose up -d
echo ""
docker compose ps
echo ""
echo -e "${GREEN}✓ Lab running. Open: http://www.seed-server.com  OR  http://localhost:10080${RESET}"
