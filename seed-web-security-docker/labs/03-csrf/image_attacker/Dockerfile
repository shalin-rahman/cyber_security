# ==============================================================================
# SEED Labs 2.0 — Attacker Web Server Dockerfile (CSRF Attacker Site)
#
# Base Image: handsonsecurity/seed-server:apache-php
#   - Serves the malicious attacker website (www.attacker32.com) hosting GET/POST CSRF triggers.
# ==============================================================================

FROM handsonsecurity/seed-server:apache-php

# Copy attacker HTML/JS payloads into web root
COPY src /var/www/html
