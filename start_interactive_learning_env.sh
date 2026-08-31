#!/bin/bash
# ==============================================================================
# SEED Web Security Labs - Start All Labs
# ==============================================================================
# This script brings up ALL labs simultaneously in detached mode.
# Because each lab is on its own dedicated Docker network subnet
# (10.20.0.0/24 through 10.24.0.0/24), there will be no IP collisions.
# ==============================================================================

labs=(
  "01-sql-injection"
  "02-xss"
  "03-csrf"
  "04-clickjacking"
  "05-shellshock"
)

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting all SEED Web Security Labs..."
echo "=========================================="

for lab in "${labs[@]}"; do
  echo ">>> Starting $lab ..."
  cd "$REPO_ROOT/seed-web-security-docker/labs/$lab" || exit 1
  docker compose up -d
done

echo "=========================================="
echo "✅ All labs have been started in the background."
echo ""
echo "Access points:"
echo "- SQL Injection : http://localhost:10080"
echo "- XSS           : http://localhost:10081"
echo "- CSRF Target   : http://www.seed-server.com:10082"
echo "- CSRF Attacker : http://www.attacker32.com:10083"
echo "- Clickjacking (Target)   : http://localhost:10084"
echo "- Clickjacking (Attacker) : http://localhost:10085"
echo "- Shellshock    : http://localhost:10086/cgi-bin/vul.cgi"
echo ""
echo "Use './stop_interactive_learning_env.sh' to tear them all down when finished."
