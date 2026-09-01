#!/bin/bash
# ==============================================================================
# SEED Web Security Labs - Open Labs in Browser
# ==============================================================================
# This script automatically opens all the running SEED labs in your default
# web browser. It uses the correct official domains for CSRF and Clickjacking.
# ==============================================================================

echo "🌐 Opening all SEED labs in your default web browser..."

# Define the URLs to open
URLS=(
  "http://localhost:10080"                         # SQL Injection
  "http://localhost:10081"                         # XSS
  "http://www.seed-server.com:10082"               # CSRF Target (Elgg)
  "http://www.attacker32.com:10083"                # CSRF Attacker
  "http://www.cjlab.com:10084"                     # Clickjacking Target
  "http://www.cjlab-attacker.com:10085"            # Clickjacking Attacker
  "http://localhost:10086/cgi-bin/vul.cgi"         # Shellshock
)

# Detect OS and open URLs
for url in "${URLS[@]}"; do
  echo "  -> Opening $url"
  if grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null; then
    # Windows / WSL
    explorer.exe "$url"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open "$url"
  else
    # Linux
    xdg-open "$url"
  fi
  sleep 0.5 # Small delay to prevent browser tab crashing
done

echo ""
echo "✅ All labs opened!"
echo "   (Make sure your Windows /etc/hosts file is updated for the .com domains to work!)"
