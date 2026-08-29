#!/usr/bin/env bash
# =============================================================================
# SEED Web Security Docker — Cleanup Script
# Safely removes lab containers, networks, and optionally images/volumes
# Usage: ./scripts/cleanup.sh [--all]
# =============================================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BOLD='\033[1m'; RESET='\033[0m'

ALL_MODE=false
[[ "${1:-}" == "--all" ]] && ALL_MODE=true

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║         SEED Web Security Docker — Cleanup               ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""

LABS=("01-sql-injection" "02-xss" "03-csrf" "04-clickjacking" "05-shellshock")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABS_DIR="$SCRIPT_DIR/../labs"

# ── Step 1: Stop all lab containers ──────────────────────────────────────────
echo -e "${YELLOW}Step 1: Stopping all lab containers...${RESET}"
for lab in "${LABS[@]}"; do
  LAB_PATH="$LABS_DIR/$lab"
  if [[ -f "$LAB_PATH/docker-compose.yml" ]]; then
    echo -e "  Stopping $lab..."
    cd "$LAB_PATH"
    docker compose down 2>/dev/null && echo -e "  ${GREEN}✓ $lab stopped${RESET}" || echo -e "  (already stopped)"
    cd "$SCRIPT_DIR"
  fi
done
echo ""

# ── Step 2: Remove SEED networks ─────────────────────────────────────────────
echo -e "${YELLOW}Step 2: Removing SEED lab networks...${RESET}"
SEED_NETWORKS=$(docker network ls --filter "name=net-10.9.0.0" -q 2>/dev/null)
if [[ -n "$SEED_NETWORKS" ]]; then
  echo "$SEED_NETWORKS" | xargs docker network rm 2>/dev/null && \
    echo -e "  ${GREEN}✓ SEED networks removed${RESET}" || \
    echo -e "  Some networks could not be removed (containers still attached?)"
else
  echo -e "  No SEED networks found"
fi
echo ""

# ── Step 3 (optional): Remove images ─────────────────────────────────────────
if $ALL_MODE; then
  echo -e "${RED}⚠️  Step 3: Removing SEED Docker images...${RESET}"
  echo -e "${RED}    WARNING: This will require re-downloading images (~5-10 GB) next time.${RESET}"
  read -rp "    Continue? [y/N]: " confirm
  if [[ "${confirm,,}" == "y" ]]; then
    SEED_IMAGES=$(docker image ls --filter "reference=handsonsecurity/*" -q 2>/dev/null)
    if [[ -n "$SEED_IMAGES" ]]; then
      echo "$SEED_IMAGES" | xargs docker image rm 2>/dev/null && \
        echo -e "  ${GREEN}✓ SEED images removed${RESET}"
    else
      echo -e "  No SEED images found"
    fi
    echo -e "${YELLOW}  Removing build cache...${RESET}"
    docker builder prune -f 2>/dev/null && echo -e "  ${GREEN}✓ Build cache cleared${RESET}"
  else
    echo -e "  Skipped image removal."
  fi
  echo ""
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo -e "${BOLD}── Cleanup complete ─────────────────────────────────────────${RESET}"
echo -e "  Current Docker disk usage:"
docker system df 2>/dev/null
echo ""
echo -e "  To remove images as well: ${YELLOW}./scripts/cleanup.sh --all${RESET}"
echo -e "  To start a fresh lab:     ${GREEN}cd labs/<lab> && docker compose up -d${RESET}"
echo ""
