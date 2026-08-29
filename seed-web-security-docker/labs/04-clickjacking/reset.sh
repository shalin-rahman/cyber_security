#!/usr/bin/env bash
docker compose down && docker compose up -d && echo "✓ Clickjacking lab reset."
