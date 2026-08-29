#!/usr/bin/env bash
docker compose up -d && docker compose ps
echo "✓ Shellshock Lab running → http://www.seedlab-shellshock.com/cgi-bin/vul.cgi (Port 10086)"
