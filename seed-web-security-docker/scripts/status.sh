#!/usr/bin/env bash
# =============================================================================
# SEED Web Security Docker — Status Script
# Shows all running lab containers and their port mappings
# Usage: ./scripts/status.sh
# =============================================================================

BOLD='\033[1m'; BLUE='\033[0;34m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; RESET='\033[0m'

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║         SEED Web Security Docker — Lab Status            ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""

echo -e "${BLUE}── All Docker Containers ─────────────────────────────────────${RESET}"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || \
  echo "  Docker daemon is not running."
echo ""

echo -e "${BLUE}── Docker Networks (SEED Labs) ───────────────────────────────${RESET}"
docker network ls --filter "name=net-10.9.0.0" --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}" 2>/dev/null
echo ""

echo -e "${BLUE}── Disk Usage ────────────────────────────────────────────────${RESET}"
docker system df 2>/dev/null || echo "  (Docker not available)"
echo ""

echo -e "${BLUE}── Quick Lab URLs ────────────────────────────────────────────${RESET}"
echo -e "  Lab 01 SQL Injection  → ${GREEN}http://www.seed-server.com${RESET}   (port 10080)"
echo -e "  Lab 02 XSS            → ${GREEN}http://www.seed-server.com${RESET}   (port 10081)"
echo -e "  Lab 03 CSRF           → ${GREEN}http://www.seed-server.com${RESET}   (port 10082)"
echo -e "  Lab 03 CSRF Attacker  → ${GREEN}http://www.attacker32.com${RESET}    (port 10083)"
echo -e "  Lab 04 Clickjacking   → ${GREEN}http://www.cjlab.com${RESET}         (port 10084)"
echo -e "  Lab 05 Shellshock     → ${GREEN}http://www.seedlab-shellshock.com${RESET} (port 10086)"
echo ""
echo -e "${YELLOW}Note: Hostnames require /etc/hosts entries. See each lab's README.md.${RESET}"
echo ""
