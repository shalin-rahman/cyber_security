# ==============================================================================
# SEED Labs 2.0 — Target Web Server Dockerfile (Clickjacking Target Site)
#
# Base Image: handsonsecurity/seed-server:apache-php
#   - Serves the legitimate target portal (www.cjlab.com) containing privileged buttons.
# ==============================================================================

FROM handsonsecurity/seed-server:apache-php

# Copy target site HTML into web root
COPY src /var/www/html
