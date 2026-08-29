#!/usr/bin/env bash
# Lab 04 — Clickjacking Attack Lab: Reset Script
echo "[Lab 04] Clickjacking Attack Lab — Reset"
echo "WARNING: Containers will be rebuilt from scratch."
read -rp "Type 'yes' to proceed: " confirm
[[ "$confirm" != "yes" ]] && echo "Cancelled." && exit 0
docker compose down -v
docker compose up -d --build
echo "Lab 04 reset complete."
echo "  Target:   http://localhost:10084"
echo "  Attacker: http://localhost:10085"
