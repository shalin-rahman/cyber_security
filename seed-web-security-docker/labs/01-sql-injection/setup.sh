#!/usr/bin/env bash
# ==============================================================================
# Lab 01 — SQL Injection Attack Lab: Setup Script (Linux / macOS / WSL)
#
# What this script does:
#   1. Checks that Docker is installed and running.
#   2. Adds the required hostname mapping to /etc/hosts so that
#      'www.seed-server.com' resolves to the container's IP (10.9.0.5)
#      inside your browser — matching the official SEED lab domain names.
#   3. Builds the Docker images locally from the Dockerfiles in image_www/
#      and image_mysql/. Building locally is required because SEED Labs
#      provides the vulnerable application source code as local files,
#      not as pre-built images on Docker Hub.
#
# Usage:
#   chmod +x setup.sh
#   sudo ./setup.sh          # sudo needed to write /etc/hosts
# ==============================================================================

set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${BOLD}[Lab 01] SQL Injection Attack Lab — Setup${RESET}"
echo "----------------------------------------------"

# Step 1: Verify Docker is available
# 'command -v docker' checks if the docker binary exists on PATH.
# If not found, the lab cannot run — exit with a clear error.
if ! command -v docker &>/dev/null; then
    echo -e "${RED}ERROR: Docker not found. Install Docker Desktop and ensure it is running.${RESET}"
    exit 1
fi

# Verify Docker daemon is actually running (not just installed)
if ! docker info &>/dev/null; then
    echo -e "${RED}ERROR: Docker daemon is not running. Start Docker Desktop first.${RESET}"
    exit 1
fi

echo -e "${GREEN}Docker is running.${RESET}"
echo ""

# Step 2: Configure /etc/hosts for hostname resolution
#
# The SEED SQL Injection lab expects the web app to be accessible at
# http://www.seed-server.com — the same hostname used in all lab manual
# screenshots and task instructions.
#
# The hosts file is a local DNS override: when your browser looks up
# 'www.seed-server.com', the OS consults this file BEFORE any DNS server.
# We map it to 10.9.0.5 — the static IP assigned to the web container
# in docker-compose.yml.
HOSTS_ENTRY="10.9.0.5   www.seed-server.com"
HOSTS_FILE="/etc/hosts"

if grep -q "www.seed-server.com" "$HOSTS_FILE" 2>/dev/null; then
    echo -e "${GREEN}hosts file already contains 'www.seed-server.com' — no change needed.${RESET}"
else
    echo -e "${YELLOW}Adding hostname entry to $HOSTS_FILE (requires sudo)...${RESET}"
    echo "$HOSTS_ENTRY" | sudo tee -a "$HOSTS_FILE" > /dev/null
    echo -e "${GREEN}Added: $HOSTS_ENTRY${RESET}"
fi

echo ""

# Step 3: Build Docker images from local Dockerfiles
#
# 'docker compose build' reads docker-compose.yml and executes the
# Dockerfile in image_www/ and image_mysql/.
#
# image_www/Dockerfile  -> extends handsonsecurity/seed-server:apache-php
#                          and copies the vulnerable PHP app into /var/www/html
# image_mysql/Dockerfile -> extends mysql:8.0 and loads sqllab_users.sql
#                           (creates the 'credential' table with employee records)
#
# '--no-cache' is used here to guarantee a fresh rebuild, ensuring any edits
# to source files are included in the new image.
echo "Building lab container images from local Dockerfiles..."
echo "(First build may take a few minutes — downloading base images)"
docker compose build --no-cache

echo ""
echo -e "${GREEN}Setup complete.${RESET}"
echo "  Run:   ./start.sh    to start the lab"
echo "  Run:   ./stop.sh     to stop the lab"
echo "  Run:   ./reset.sh    to wipe data and restart from scratch"
