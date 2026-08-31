#!/bin/bash
# ==============================================================================
# SEED Web Security Labs - Stop All Labs
# ==============================================================================
# This script brings down all running labs and cleans up their networks.
# ==============================================================================

labs=(
  "01-sql-injection"
  "02-xss"
  "03-csrf"
  "04-clickjacking"
  "05-shellshock"
)

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Stopping all SEED Web Security Labs..."
echo "=========================================="

for lab in "${labs[@]}"; do
  echo ">>> Stopping $lab ..."
  cd "$REPO_ROOT/seed-web-security-docker/labs/$lab" || exit 1
  docker compose down -v
done

echo "=========================================="
echo "✅ All labs have been stopped and networks removed."
