#!/usr/bin/env bash
# Lab 03 — CSRF Attack Lab: Reset Script
echo "[Lab 03] CSRF Attack Lab — Reset"
echo "WARNING: All database changes will be wiped."
read -rp "Type 'yes' to proceed: " confirm
[[ "$confirm" != "yes" ]] && echo "Cancelled." && exit 0
docker compose down -v
docker compose up -d --build
echo "Lab 03 reset complete."
echo "  Target site:   http://localhost:10082"
echo "  Attacker site: http://localhost:10083"
