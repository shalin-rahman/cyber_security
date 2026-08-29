#!/usr/bin/env bash
# ==============================================================================
# Lab 01 — SQL Injection Attack Lab: Start Script
#
# What this script does:
#   1. Starts both containers defined in docker-compose.yml in detached mode.
#   2. Prints container status to confirm both are running.
#   3. Displays the URL to open in your browser.
#
# Container Architecture (from docker-compose.yml):
#   www-10.9.0.5    -> Apache web server serving the vulnerable PHP app (port 10080)
#   mysql-10.9.0.6  -> MySQL 8.0 database holding the 'credential' employee table
#
# Both containers share a private Docker network (net-10.9.0.0/24).
# The web container connects to MySQL at 10.9.0.6 — a fixed IP, not 'localhost'.
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}[Lab 01] SQL Injection Attack Lab — Starting Containers${RESET}"
echo "--------------------------------------------------------"

# '-d' means detached mode: containers run in the background.
# Without -d, the terminal would be locked to container log output.
docker compose up -d

echo ""

# Show running container status (name, image, ports, health)
docker compose ps

echo ""
echo -e "${GREEN}Lab 01 is running.${RESET}"
echo ""
echo "  Browser access:"
echo "    http://www.seed-server.com     (if hosts file configured)"
echo "    http://localhost:10080         (direct port mapping — always works)"
echo ""
echo "  Container shell access (Layer 1 — Linux inspection):"
echo "    docker exec -it www-10.9.0.5 bash"
echo "    docker exec -it mysql-10.9.0.6 bash"
echo ""
echo "  MySQL direct access (from inside mysql container):"
echo "    docker exec -it mysql-10.9.0.6 mysql -u root -pdees sqllab_users"
