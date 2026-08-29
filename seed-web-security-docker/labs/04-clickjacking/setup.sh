#!/usr/bin/env bash
# ==============================================================================
# Lab 04 — Clickjacking Attack Lab: Setup Script
#
# Containers:
#   cjlab-10.9.0.80        -> Legitimate target site (www.cjlab.com) on port 10084
#   cjlab-attacker-10.9.0.81 -> Malicious overlay site (www.cjlab-attacker.com) on port 10085
#
# Two hostnames required:
#   www.cjlab.com          -> the legitimate site with the "Delete Account" button
#   www.cjlab-attacker.com -> the attacker page that overlays a transparent iframe
#                             covering the legitimate button with a fake "WIN A PRIZE" button
#
# The attack works because:
#   1. The attacker page loads the target site inside a hidden <iframe>
#   2. The iframe is positioned so the dangerous button aligns with a fake button
#   3. The victim clicks the fake button but actually clicks the real dangerous one
# ==============================================================================

set -euo pipefail
BOLD='\033[1m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; RESET='\033[0m'

echo -e "${BOLD}[Lab 04] Clickjacking Attack Lab — Setup${RESET}"
echo "------------------------------------------"

if ! command -v docker &>/dev/null; then echo -e "${RED}ERROR: Docker not found.${RESET}" && exit 1; fi
if ! docker info &>/dev/null; then echo -e "${RED}ERROR: Docker not running.${RESET}" && exit 1; fi
echo -e "${GREEN}Docker is running.${RESET}"; echo ""

HOSTS_FILE="/etc/hosts"
for entry in "10.9.0.80   www.cjlab.com" "10.9.0.81   www.cjlab-attacker.com"; do
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
