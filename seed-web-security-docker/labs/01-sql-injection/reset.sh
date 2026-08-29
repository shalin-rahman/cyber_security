#!/usr/bin/env bash
# SQL Injection Lab — Reset Script
# ⚠️  WARNING: Removes all database volumes — resets to original state
echo "⚠️  This will destroy all database changes and restore original lab data."
read -rp "Proceed? [y/N]: " confirm
[[ "${confirm,,}" != "y" ]] && echo "Reset cancelled." && exit 0
docker compose down -v
docker compose up -d
echo "✓ Lab reset to original state."
