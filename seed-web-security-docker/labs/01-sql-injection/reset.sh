#!/usr/bin/env bash
# ==============================================================================
# Lab 01 — SQL Injection Attack Lab: Reset Script
#
# What this script does:
#   Completely destroys all containers, networks, AND database volumes,
#   then rebuilds images and starts fresh containers with the original
#   database state (from sqllab_users.sql).
#
# Use this when:
#   - You accidentally corrupted the database with an UPDATE injection
#   - You want to redo all tasks from a clean state
#   - The containers are in a broken state
#
# WARNING: All changes made to the database (salary modifications, etc.)
# will be permanently lost. This action cannot be undone.
# ==============================================================================

echo "[Lab 01] SQL Injection Attack Lab — Reset"
echo "WARNING: This will destroy all database changes and restore original lab data."
echo ""
read -rp "Are you sure? Type 'yes' to proceed: " confirm

if [[ "$confirm" != "yes" ]]; then
    echo "Reset cancelled. No changes made."
    exit 0
fi

echo ""
echo "Stopping containers and removing volumes..."

# '-v' flag removes named Docker volumes (the MySQL data directory).
# Without -v, 'docker compose down' preserves data volumes.
# With -v, the database is completely erased — MySQL will re-run
# sqllab_users.sql on the next startup, restoring original data.
docker compose down -v

echo "Rebuilding images and starting fresh containers..."

# '--build' forces Docker to rebuild images from Dockerfiles.
# This ensures any code changes are included in the new containers.
docker compose up -d --build

echo ""
echo "Lab 01 reset complete. Original database has been restored."
echo "Access: http://localhost:10080"
