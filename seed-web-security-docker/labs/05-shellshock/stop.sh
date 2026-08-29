#!/usr/bin/env bash
# Lab 05 — Shellshock Vulnerability Lab: Stop Script
echo "[Lab 05] Shellshock Vulnerability Lab — Stopping container..."
docker compose down
echo "Lab 05 stopped. Run ./start.sh to resume."
