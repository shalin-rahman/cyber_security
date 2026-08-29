#!/usr/bin/env bash
# ==============================================================================
# Lab 02 — XSS Attack Lab: Setup Script
#
# What this script does:
#   1. Verifies Docker is installed and running.
#   2. Adds hostname entries to /etc/hosts for the Elgg social network domain.
#   3. Builds Docker images from local Dockerfiles.
#
# Hostname mapping:
#   10.9.0.5  -> www.seed-server.com  (Elgg social network — the victim site)
#
# The XSS lab uses the Elgg social network application.
# Users (Alice, Boby, Samy) create profiles. Samy (attacker) injects a
# malicious JavaScript payload into his "About Me" field. When Alice views
# Samy's profile, her browser executes the injected script — demonstrating
# a stored (persistent) XSS attack.
# ==============================================================================

set -euo pipefail
BOLD='\033[1m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; RESET='\033[0m'

echo -e "${BOLD}[Lab 02] XSS Attack Lab — Setup${RESET}"
echo "---------------------------------------"

if ! command -v docker &>/dev/null; then
    echo -e "${RED}ERROR: Docker not found.${RESET}" && exit 1
fi
if ! docker info &>/dev/null; then
    echo -e "${RED}ERROR: Docker daemon is not running. Start Docker Desktop.${RESET}" && exit 1
fi
echo -e "${GREEN}Docker is running.${RESET}"
echo ""

HOSTS_FILE="/etc/hosts"
declare -A ENTRIES=(
    ["www.seed-server.com"]="10.9.0.5"
)

for host in "${!ENTRIES[@]}"; do
    ip="${ENTRIES[$host]}"
    if grep -q "$host" "$HOSTS_FILE" 2>/dev/null; then
        echo -e "${GREEN}hosts already contains '$host' — skipped.${RESET}"
    else
        echo -e "${YELLOW}Adding: $ip   $host${RESET}"
        echo "$ip   $host" | sudo tee -a "$HOSTS_FILE" > /dev/null
        echo -e "${GREEN}Added.${RESET}"
    fi
done

echo ""
echo "Building lab container images..."
docker compose build --no-cache

echo ""
echo -e "${GREEN}Setup complete.${RESET}"
echo "  Run: ./start.sh to launch the lab"
