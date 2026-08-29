#!/usr/bin/env bash
# Lab 04 — Clickjacking Attack Lab: Stop Script
echo "[Lab 04] Clickjacking Attack Lab — Stopping containers..."
docker compose down
echo "Lab 04 stopped. Run ./start.sh to resume."
