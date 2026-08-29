#!/usr/bin/env bash
docker compose up -d && docker compose ps
echo "✓ CSRF Lab running:"
echo "  Legitimate site: http://www.seed-server.com  (Port 10082)"
echo "  Attacker site:   http://www.attacker32.com   (Port 10083)"
