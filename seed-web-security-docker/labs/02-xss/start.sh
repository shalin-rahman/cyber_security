#!/usr/bin/env bash
docker compose up -d && docker compose ps
echo "✓ XSS Lab running → http://www.seed-server.com  OR  http://localhost:10081"
