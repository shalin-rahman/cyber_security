#!/usr/bin/env bash
# ==============================================================================
# Lab 04 — Clickjacking Attack Lab: Start Script
#
# Starts:
#   cjlab-10.9.0.80          -> Target site (www.cjlab.com) on port 10084
#   cjlab-attacker-10.9.0.81 -> Attacker overlay site on port 10085
#
# Lab workflow:
#   1. First, open http://www.cjlab.com — see the legitimate "Delete Account" button
#   2. Then, open http://www.cjlab-attacker.com — see the attacker's page
#   3. Observe that clicking the "WIN A PRIZE" button actually clicks the target site's
#      button underneath the invisible iframe
#   4. Use browser DevTools (F12 > Inspector) to reveal the invisible iframe layers
# ==============================================================================

set -euo pipefail
GREEN='\033[0;32m'; BOLD='\033[1m'; RESET='\033[0m'

echo -e "${BOLD}[Lab 04] Clickjacking Attack Lab — Starting Containers${RESET}"
echo "-------------------------------------------------------"
docker compose up -d
echo ""
docker compose ps
echo ""
echo -e "${GREEN}Lab 04 is running.${RESET}"
echo ""
echo "  Legitimate target site (visit first to understand the UI):"
echo "    http://www.cjlab.com              OR   http://localhost:10084"
echo ""
echo "  Attacker overlay site (demonstrates the clickjacking attack):"
echo "    http://www.cjlab-attacker.com     OR   http://localhost:10085"
echo ""
echo "  Container shell access (inspect Apache/HTML files):"
echo "    docker exec -it cjlab-10.9.0.80 bash"
echo "    docker exec -it cjlab-attacker-10.9.0.81 bash"
