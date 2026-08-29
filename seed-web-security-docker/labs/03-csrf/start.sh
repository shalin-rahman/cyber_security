#!/usr/bin/env bash
# ==============================================================================
# Lab 03 — CSRF Attack Lab: Start Script
#
# Starts three containers:
#   elgg-10.9.0.5-csrf    -> Elgg (legitimate site) on port 10082
#   attacker-10.9.0.105   -> Attacker site on port 10083
#   mysql-10.9.0.6-csrf   -> MySQL database
#
# Lab workflow:
#   1. Open http://www.seed-server.com — log in as Alice (victim)
#   2. In a new tab, visit http://www.attacker32.com
#   3. The attacker page silently triggers GET or POST requests to the
#      Elgg site using Alice's active session cookie (same-origin trust)
#   4. Observe that Alice's friend list or profile changes without her consent
# ==============================================================================

set -euo pipefail
GREEN='\033[0;32m'; BOLD='\033[1m'; RESET='\033[0m'

echo -e "${BOLD}[Lab 03] CSRF Attack Lab — Starting Containers${RESET}"
echo "------------------------------------------------"
docker compose up -d
echo ""
docker compose ps
echo ""
echo -e "${GREEN}Lab 03 is running.${RESET}"
echo ""
echo "  Legitimate target site (log in as Alice here first):"
echo "    http://www.seed-server.com     OR   http://localhost:10082"
echo ""
echo "  Malicious attacker site (visit after logging in as Alice):"
echo "    http://www.attacker32.com      OR   http://localhost:10083"
echo ""
echo "  Container shell access:"
echo "    docker exec -it elgg-10.9.0.5-csrf bash"
echo "    docker exec -it attacker-10.9.0.105 bash"
