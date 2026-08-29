#!/usr/bin/env bash
# ==============================================================================
# Lab 05 — Shellshock Vulnerability Lab: Setup Script
#
# Container:
#   shellshock-10.9.0.80  -> Apache + CGI server exposing two endpoints (port 10086)
#     /cgi-bin/vul.cgi    -> Uses bash_shellshock (vulnerable Bash 4.3 copy)
#     /cgi-bin/safe.cgi   -> Uses /bin/bash (modern patched Bash — safe)
#
# About the Shellshock vulnerability (CVE-2014-6271):
#   Bash has a bug where it executes code appended after a function definition
#   stored in environment variables. When Apache runs a CGI script, it converts
#   HTTP headers (like User-Agent, Referer) into environment variables.
#   An attacker can craft HTTP headers containing the payload:
#     () { :; }; <malicious-command>
#   Bash parses this as a function, but then immediately executes the extra command.
#
# The lab demonstrates this using curl with a crafted User-Agent header.
# ==============================================================================

set -euo pipefail
BOLD='\033[1m'; GREEN='\033[0;32m'; RED='\033[0;31m'; RESET='\033[0m'

echo -e "${BOLD}[Lab 05] Shellshock Vulnerability Lab — Setup${RESET}"
echo "----------------------------------------------"

if ! command -v docker &>/dev/null; then echo -e "${RED}ERROR: Docker not found.${RESET}" && exit 1; fi
if ! docker info &>/dev/null; then echo -e "${RED}ERROR: Docker not running.${RESET}" && exit 1; fi
echo -e "${GREEN}Docker is running.${RESET}"; echo ""

# No /etc/hosts entry needed for Lab 05 — accessing directly via localhost:10086
echo "No hostname configuration required for this lab."
echo "The server will be accessible at http://localhost:10086"
echo ""

echo "Building lab container image..."
docker compose build --no-cache
echo ""
echo -e "${GREEN}Setup complete. Run ./start.sh to launch the lab.${RESET}"
