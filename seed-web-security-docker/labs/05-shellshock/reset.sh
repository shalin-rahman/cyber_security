#!/usr/bin/env bash
# Lab 05 — Shellshock Vulnerability Lab: Reset Script
echo "[Lab 05] Shellshock Vulnerability Lab — Reset"
read -rp "Rebuild container from scratch? Type 'yes' to proceed: " confirm
[[ "$confirm" != "yes" ]] && echo "Cancelled." && exit 0
docker compose down -v
docker compose up -d --build
echo "Lab 05 reset complete. Access: http://localhost:10086/cgi-bin/vul.cgi"
