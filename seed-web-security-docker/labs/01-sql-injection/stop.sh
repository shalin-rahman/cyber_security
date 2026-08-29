#!/usr/bin/env bash
# ==============================================================================
# Lab 01 — SQL Injection Attack Lab: Stop Script
#
# What this script does:
#   Stops and removes the running containers and the Docker network.
#   Database volumes are PRESERVED — your changes (injections, updates)
#   persist and will still be there when you run start.sh again.
#
# To completely wipe all data, use reset.sh instead.
# ==============================================================================

echo "[Lab 01] SQL Injection Attack Lab — Stopping containers..."

# 'docker compose down' stops containers and removes:
#   - the container processes
#   - the virtual network (net-10.9.0.0-sqli)
# It does NOT remove named volumes (database data is kept).
docker compose down

echo "Lab 01 stopped. Database data is preserved."
echo "Run ./start.sh to resume, or ./reset.sh to wipe and start fresh."
