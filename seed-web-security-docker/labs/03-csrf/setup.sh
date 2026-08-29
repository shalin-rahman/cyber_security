#!/usr/bin/env bash
# ==============================================================================
# Lab 03 — CSRF Attack Lab: Setup Script
#
# Containers started by this lab:
#   elgg-10.9.0.5-csrf     -> Legitimate Elgg social network (www.seed-server.com)
#   attacker-10.9.0.105    -> Malicious attacker website (www.attacker32.com)
#   mysql-10.9.0.6-csrf    -> Database for the Elgg application
#
# Two domains are needed because CSRF exploits the browser's trust in cookies
# sent across origins. The attack only works when the victim visits the
# attacker's domain WHILE being authenticated on the target domain.
# This two-container setup simulates exactly that cross-origin scenario.
# ==============================================================================

set -euo pipefail
BOLD='\033[1m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; RESET='\033[0m'

echo -e "${BOLD}[Lab 03] CSRF Attack Lab — Setup${RESET}"
echo "---------------------------------------"

if ! command -v docker &>/dev/null; then echo -e "${RED}ERROR: Docker not found.${RESET}" && exit 1; fi
if ! docker info &>/dev/null; then echo -e "${RED}ERROR: Docker not running.${RESET}" && exit 1; fi
echo -e "${GREEN}Docker is running.${RESET}"; echo ""

HOSTS_FILE="/etc/hosts"

# Two hostnames required:
#   www.seed-server.com  -> the legitimate trusted site (victim is logged in here)
#   www.attacker32.com   -> the malicious site that triggers forged requests
for entry in "10.9.0.5   www.seed-server.com" "10.9.0.105   www.attacker32.com"; do
    host=$(echo "$entry" | awk '{print $2}')
    if grep -q "$host" "$HOSTS_FILE" 2>/dev/null; then
        echo -e "${GREEN}hosts already contains '$host' — skipped.${RESET}"
    else
        echo -e "${YELLOW}Adding: $entry${RESET}"
        echo "$entry" | sudo tee -a "$HOSTS_FILE" > /dev/null
        echo -e "${GREEN}Added.${RESET}"
    fi
done

echo ""
echo "Building lab container images..."
docker compose build --no-cache
echo ""
echo -e "${GREEN}Setup complete. Run ./start.sh to launch the lab.${RESET}"
