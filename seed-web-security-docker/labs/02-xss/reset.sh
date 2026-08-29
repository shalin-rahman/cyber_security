#!/usr/bin/env bash
# ==============================================================================
# Lab 02 — XSS Attack Lab: Reset Script
# Removes all containers and volumes (wipes injected profile data),
# then rebuilds images and restores original Elgg database state.
# ==============================================================================
echo "[Lab 02] XSS Attack Lab — Reset"
echo "WARNING: All profile changes (XSS payloads saved in DB) will be wiped."
read -rp "Type 'yes' to proceed: " confirm
[[ "$confirm" != "yes" ]] && echo "Cancelled." && exit 0
docker compose down -v
docker compose up -d --build
echo "Lab 02 reset complete. Access: http://localhost:10081"
