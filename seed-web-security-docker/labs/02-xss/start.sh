#!/usr/bin/env bash
# ==============================================================================
# Lab 02 — XSS Attack Lab: Start Script
#
# Starts:
#   elgg-10.9.0.5      -> Elgg social network app (port 10081)
#   mysql-10.9.0.6-xss -> MySQL holding the Elgg user/profile database
#
# Lab scenario:
#   - Open http://localhost:10081 or http://www.seed-server.com
#   - Log in as Samy and inject JavaScript into the "About Me" profile field
#   - Log in as Alice and view Samy's profile to trigger the stored XSS payload
# ==============================================================================

set -euo pipefail
GREEN='\033[0;32m'; BOLD='\033[1m'; RESET='\033[0m'

echo -e "${BOLD}[Lab 02] XSS Attack Lab — Starting Containers${RESET}"
echo "-----------------------------------------------"

docker compose up -d

echo ""
docker compose ps

echo ""
echo -e "${GREEN}Lab 02 is running.${RESET}"
echo ""
echo "  Browser access:"
echo "    http://www.seed-server.com     (if hosts file configured)"
echo "    http://localhost:10081         (direct port mapping)"
echo ""
echo "  Container shell access (Linux inspection):"
echo "    docker exec -it elgg-10.9.0.5 bash"
echo ""
echo "  Inside container — inspect Apache config:"
echo "    cat /etc/apache2/sites-enabled/000-default.conf"
echo "    ls /var/www/html"
