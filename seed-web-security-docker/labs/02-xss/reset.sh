#!/usr/bin/env bash
echo "⚠️  This resets Elgg database to original state (all posts/changes lost)."
read -rp "Proceed? [y/N]: " c; [[ "${c,,}" != "y" ]] && echo "Cancelled." && exit 0
docker compose down -v && docker compose up -d && echo "✓ XSS lab reset."
