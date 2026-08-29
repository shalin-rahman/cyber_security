#!/usr/bin/env bash
# Lab 03 — CSRF Attack Lab: Stop Script
echo "[Lab 03] CSRF Attack Lab — Stopping containers..."
docker compose down
echo "Lab 03 stopped. Run ./start.sh to resume."
