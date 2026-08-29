#!/usr/bin/env bash
echo "⚠️  This resets CSRF lab database state."
read -rp "Proceed? [y/N]: " c; [[ "${c,,}" != "y" ]] && echo "Cancelled." && exit 0
docker compose down -v && docker compose up -d && echo "✓ CSRF lab reset."
