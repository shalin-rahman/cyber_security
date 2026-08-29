#!/usr/bin/env bash
# =============================================================================
# SEED Web Security Docker — System Diagnostic Tool (Bash)
# Usage: ./scripts/doctor.sh
# =============================================================================

set -euo pipefail

BOLD='\033[1m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; RESET='\033[0m'

echo -e ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║     Cyber Security Environment Doctor & System Check     ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
echo -e ""

ERRORS=0
WARNINGS=0

# 1. Check Docker CLI
echo -n "Checking Docker CLI..."
if command -v docker &>/dev/null; then
    VER=$(docker --version | awk '{print $3}' | tr -d ',')
    echo -e " ${GREEN}[PASS] Installed ($VER)${RESET}"
else
    echo -e " ${RED}[FAIL] Docker CLI not found.${RESET}"
    ERRORS=$((ERRORS + 1))
fi

# 2. Check Docker Daemon
echo -n "Checking Docker Daemon..."
if docker info &>/dev/null; then
    echo -e " ${GREEN}[PASS] Daemon active${RESET}"
else
    echo -e " ${RED}[FAIL] Daemon not responding. Ensure Docker is running.${RESET}"
    ERRORS=$((ERRORS + 1))
fi

# 3. Check Docker Compose
echo -n "Checking Docker Compose..."
if docker compose version &>/dev/null; then
    CVER=$(docker compose version | awk '{print $4}')
    echo -e " ${GREEN}[PASS] Available ($CVER)${RESET}"
else
    echo -e " ${RED}[FAIL] Docker Compose not found.${RESET}"
    ERRORS=$((ERRORS + 1))
fi

# 4. Check Lab Ports (10080-10086)
echo -n "Checking Lab Ports (10080-10086)..."
BUSY=""
for PORT in {10080..10086}; do
    if ss -tlnp 2>/dev/null | grep -q ":$PORT " || netstat -an 2>/dev/null | grep -q ":$PORT "; then
        BUSY="$BUSY $PORT"
    fi
done
if [[ -z "$BUSY" ]]; then
    echo -e " ${GREEN}[PASS] All ports free${RESET}"
else
    echo -e " ${YELLOW}[WARN] Busy ports:$BUSY${RESET}"
    WARNINGS=$((WARNINGS + 1))
fi

# 5. Check Free Disk Space
echo -n "Checking Free Disk Space..."
FREE_GB=$(df -BG . | tail -1 | awk '{print $4}' | tr -d 'G')
if [[ $FREE_GB -ge 20 ]]; then
    echo -e " ${GREEN}[PASS] ${FREE_GB} GB available (20 GB+ recommended)${RESET}"
elif [[ $FREE_GB -ge 10 ]]; then
    echo -e " ${YELLOW}[WARN] ${FREE_GB} GB available (10 GB minimum)${RESET}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e " ${RED}[FAIL] Only ${FREE_GB} GB available. Free up disk space.${RESET}"
    ERRORS=$((ERRORS + 1))
fi

echo -e ""
echo -e "${BOLD}── Doctor Summary ─────────────────────────────────────────${RESET}"
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "  ${GREEN}[PASS] System environment is fully operational.${RESET}"
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "  ${YELLOW}[WARN] System ready with $WARNINGS warning(s). Review above.${RESET}"
else
    echo -e "  ${RED}[FAIL] Environment NOT ready. Resolve $ERRORS error(s) before starting.${RESET}"
fi
echo -e ""
