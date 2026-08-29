#!/usr/bin/env bash
# =============================================================================
# SEED Web Security Docker — Environment Validation Script
# Usage: ./scripts/check-environment.sh
# =============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; RESET='\033[0m'

PASS="${GREEN}[PASS]${RESET}"
WARN="${YELLOW}[WARNING]${RESET}"
FAIL="${RED}[ERROR]${RESET}"

ERRORS=0
WARNINGS=0

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║     SEED Web Security Docker — Environment Check         ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""

# ── 1. Operating System ───────────────────────────────────────────────────────
echo -e "${BLUE}── Operating System ─────────────────────────────────────────${RESET}"
OS="$(uname -s)"
case "$OS" in
  Linux*)
    DISTRO="$(grep -oP '(?<=^ID=).+' /etc/os-release 2>/dev/null | tr -d '"' || echo "unknown")"
    echo -e "$PASS  Operating system: Linux ($DISTRO)"
    ;;
  Darwin*)
    MACOS_VER="$(sw_vers -productVersion 2>/dev/null || echo "unknown")"
    echo -e "$PASS  Operating system: macOS $MACOS_VER"
    ;;
  CYGWIN*|MINGW*|MSYS*)
    echo -e "$PASS  Operating system: Windows (Git Bash / MSYS2)"
    ;;
  *)
    echo -e "$WARN  Operating system: $OS (may have compatibility issues)"
    ((WARNINGS++)) || true
    ;;
esac
echo ""

# ── 2. Docker Installation ────────────────────────────────────────────────────
echo -e "${BLUE}── Docker ───────────────────────────────────────────────────${RESET}"
if command -v docker &>/dev/null; then
  DOCKER_VER="$(docker --version 2>/dev/null)"
  echo -e "$PASS  Docker installed: $DOCKER_VER"
else
  echo -e "$FAIL  Docker is not installed."
  echo        "      Install: https://docs.docker.com/get-docker/"
  ((ERRORS++)) || true
fi

# ── 3. Docker Daemon ──────────────────────────────────────────────────────────
if command -v docker &>/dev/null; then
  if docker info &>/dev/null 2>&1; then
    echo -e "$PASS  Docker daemon is running"
  else
    echo -e "$FAIL  Docker daemon is NOT running."
    echo        "      Windows/macOS: Start Docker Desktop"
    echo        "      Linux: sudo systemctl start docker"
    ((ERRORS++)) || true
  fi
fi
echo ""

# ── 4. Docker Compose ─────────────────────────────────────────────────────────
echo -e "${BLUE}── Docker Compose ───────────────────────────────────────────${RESET}"
if docker compose version &>/dev/null 2>&1; then
  COMPOSE_VER="$(docker compose version 2>/dev/null)"
  echo -e "$PASS  Docker Compose (plugin): $COMPOSE_VER"
elif command -v docker-compose &>/dev/null; then
  COMPOSE_VER="$(docker-compose --version 2>/dev/null)"
  echo -e "$WARN  Legacy docker-compose found: $COMPOSE_VER"
  echo        "      Recommend upgrading to Docker Compose v2 plugin."
  ((WARNINGS++)) || true
else
  echo -e "$FAIL  Docker Compose is not available."
  echo        "      Install: https://docs.docker.com/compose/install/"
  ((ERRORS++)) || true
fi
echo ""

# ── 5. RAM ────────────────────────────────────────────────────────────────────
echo -e "${BLUE}── System Resources ─────────────────────────────────────────${RESET}"
MIN_RAM_GB=8
REC_RAM_GB=16

if [[ "$OS" == "Linux" ]] || [[ "$OS" == *"CYGWIN"* ]] || [[ "$OS" == *"MINGW"* ]]; then
  RAM_KB="$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}' || echo 0)"
  RAM_GB=$(( RAM_KB / 1024 / 1024 ))
elif [[ "$OS" == "Darwin" ]]; then
  RAM_BYTES="$(sysctl -n hw.memsize 2>/dev/null || echo 0)"
  RAM_GB=$(( RAM_BYTES / 1024 / 1024 / 1024 ))
else
  RAM_GB=0
fi

if [[ $RAM_GB -ge $REC_RAM_GB ]]; then
  echo -e "$PASS  RAM: ${RAM_GB} GB (recommended: ${REC_RAM_GB} GB)"
elif [[ $RAM_GB -ge $MIN_RAM_GB ]]; then
  echo -e "$WARN  RAM: ${RAM_GB} GB (minimum met; recommended: ${REC_RAM_GB} GB — performance may be limited)"
  ((WARNINGS++)) || true
else
  echo -e "$FAIL  RAM: ${RAM_GB} GB — minimum ${MIN_RAM_GB} GB required."
  ((ERRORS++)) || true
fi

# ── 6. Disk Space ─────────────────────────────────────────────────────────────
MIN_DISK_GB=20
REC_DISK_GB=40

DISK_AVAIL_KB="$(df -k . 2>/dev/null | awk 'NR==2 {print $4}' || echo 0)"
DISK_AVAIL_GB=$(( DISK_AVAIL_KB / 1024 / 1024 ))

if [[ $DISK_AVAIL_GB -ge $REC_DISK_GB ]]; then
  echo -e "$PASS  Free disk: ${DISK_AVAIL_GB} GB (recommended: ${REC_DISK_GB} GB)"
elif [[ $DISK_AVAIL_GB -ge $MIN_DISK_GB ]]; then
  echo -e "$WARN  Free disk: ${DISK_AVAIL_GB} GB (minimum met; recommended: ${REC_DISK_GB} GB)"
  ((WARNINGS++)) || true
else
  echo -e "$FAIL  Free disk: ${DISK_AVAIL_GB} GB — minimum ${MIN_DISK_GB} GB required."
  ((ERRORS++)) || true
fi

# ── 7. CPU Cores ──────────────────────────────────────────────────────────────
MIN_CPU=4
if [[ "$OS" == "Darwin" ]]; then
  CPU_COUNT="$(sysctl -n hw.logicalcpu 2>/dev/null || echo 0)"
else
  CPU_COUNT="$(nproc 2>/dev/null || grep -c '^processor' /proc/cpuinfo 2>/dev/null || echo 0)"
fi

if [[ $CPU_COUNT -ge $MIN_CPU ]]; then
  echo -e "$PASS  CPU cores: $CPU_COUNT (minimum: $MIN_CPU)"
else
  echo -e "$WARN  CPU cores: $CPU_COUNT (minimum: $MIN_CPU — performance may be limited)"
  ((WARNINGS++)) || true
fi
echo ""

# ── 8. Internet Connectivity ──────────────────────────────────────────────────
echo -e "${BLUE}── Internet Connectivity ────────────────────────────────────${RESET}"
if curl -s --connect-timeout 5 https://hub.docker.com &>/dev/null; then
  echo -e "$PASS  Docker Hub reachable (https://hub.docker.com)"
elif curl -s --connect-timeout 5 https://google.com &>/dev/null; then
  echo -e "$WARN  Internet available but Docker Hub may be restricted"
  ((WARNINGS++)) || true
else
  echo -e "$FAIL  No internet connectivity — required for pulling Docker images"
  ((ERRORS++)) || true
fi
echo ""

# ── 9. Required Tools ─────────────────────────────────────────────────────────
echo -e "${BLUE}── Optional Tools ───────────────────────────────────────────${RESET}"
for tool in curl wget git; do
  if command -v $tool &>/dev/null; then
    echo -e "$PASS  $tool: $(command -v $tool)"
  else
    echo -e "$WARN  $tool not found (recommended but not required)"
    ((WARNINGS++)) || true
  fi
done
echo ""

# ── Summary ───────────────────────────────────────────────────────────────────
echo -e "${BOLD}── Summary ──────────────────────────────────────────────────${RESET}"
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}✅  Environment is ready. All checks passed.${RESET}"
elif [[ $ERRORS -eq 0 ]]; then
  echo -e "${YELLOW}${BOLD}⚠️   Environment ready with $WARNINGS warning(s). Review above.${RESET}"
else
  echo -e "${RED}${BOLD}❌  Environment NOT ready. $ERRORS error(s) must be fixed.${RESET}"
  echo -e "    See docs/01-prerequisites.md for installation instructions."
fi
echo ""
