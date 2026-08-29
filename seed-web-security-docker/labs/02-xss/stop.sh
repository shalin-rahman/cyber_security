#!/usr/bin/env bash
# ==============================================================================
# Lab 02 — XSS Attack Lab: Stop Script
# Stops containers, preserves database volumes (profile data kept).
# ==============================================================================
echo "[Lab 02] XSS Attack Lab — Stopping containers..."
docker compose down
echo "Lab 02 stopped. Profile data preserved."
echo "Run ./start.sh to resume, or ./reset.sh to wipe data."
