#!/usr/bin/env bash
docker compose up -d && docker compose ps
echo "✓ Clickjacking Lab running:"
echo "  Target site:   http://www.cjlab.com          (Port 10084)"
echo "  Attacker site: http://www.cjlab-attacker.com (Port 10085)"
