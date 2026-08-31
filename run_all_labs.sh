#!/usr/bin/env bash
# =============================================================================
# run_all_labs.sh – SEED Web-Security Docker Lab Runner
#
# Usage:
#   ./run_all_labs.sh              # interactive (opens log after each lab)
#   ./run_all_labs.sh --no-ui      # non-interactive CI / scripted run
# =============================================================================
set -euo pipefail

# ── CLI flag ──────────────────────────────────────────────────────────────────
UI=true
if [[ "${1:-}" == "--no-ui" ]]; then
  UI=false
fi

# ── Port map (lab → space-separated ports) ────────────────────────────────────
declare -A PORTS=(
  ["01-sql-injection"]="10080"
  ["02-xss"]="10081"
  ["03-csrf"]="10082 10083"
  ["04-clickjacking"]="10084 10085"
  ["05-shellshock"]="10086"
)

# ── Special health-check paths ────────────────────────────────────────────────
declare -A PATHS=(
  ["05-shellshock"]="/cgi-bin/vul.cgi"
)

# ── Sleep override per lab (default 10 s) ────────────────────────────────────
declare -A SLEEP=(
  ["05-shellshock"]="15"
)

# ── Lab list ──────────────────────────────────────────────────────────────────
labs=(
  "01-sql-injection"
  "02-xss"
  "03-csrf"
  "04-clickjacking"
  "05-shellshock"
)

# ── Log directory (relative to repo root) ────────────────────────────────────
REPO_ROOT="$(pwd)"
LOG_DIR="$REPO_ROOT/lab_logs"
mkdir -p "$LOG_DIR"

# ── Helper: run a single health-check request ─────────────────────────────────
check_port() {
  local lab="$1"
  local port="$2"
  local path="${PATHS[$lab]:-/}"
  local url="http://localhost:${port}${path}"
  local logfile="$LOG_DIR/${lab}_run.log"

  echo ""
  echo "  → Request:  GET $url"

  # Write full verbose output to log (for inspection)
  curl -s -v "$url" >> "$logfile" 2>&1

  # Check HTTP status code reliably
  local http_code
  http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")

  echo "  ← Response: HTTP $http_code"

  if [[ "$http_code" =~ ^(200|301|302)$ ]]; then
    echo "  ✔ Status OK"
  else
    echo "  ✘ Lab $lab failed on port $port (HTTP $http_code)"
    exit 1
  fi
}

# ── Main loop ─────────────────────────────────────────────────────────────────
for lab in "${labs[@]}"; do
  echo ""
  echo "══════════════════════════════════════════"
  echo "  Testing : $lab"
  echo "  Ports   : ${PORTS[$lab]}"
  echo "══════════════════════════════════════════"

  LOGFILE="$LOG_DIR/${lab}_run.log"
  : > "$LOGFILE"   # clear previous log

  cd "seed-web-security-docker/labs/$lab"
  docker compose up -d

  # Wait for service to initialise
  wait_secs="${SLEEP[$lab]:-10}"
  echo "  Waiting ${wait_secs}s for services…"
  sleep "$wait_secs"

  docker compose ps

  # Health-check each published port
  for port in ${PORTS[$lab]}; do
    check_port "$lab" "$port"
  done

  docker compose down -v
  cd "$REPO_ROOT"

  echo ""
  echo "  ✅ $lab PASSED"
  echo "  Log : $LOGFILE"

  # Open log in Notepad (interactive mode only)
  if $UI && command -v cygpath &>/dev/null; then
    notepad "$(cygpath -w "$LOGFILE")" &
  fi
done

echo ""
echo "══════════════════════════════════════════"
echo "  ALL LABS SUCCESSFULLY TESTED"
echo "══════════════════════════════════════════"
