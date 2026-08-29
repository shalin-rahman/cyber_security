# ==============================================================================
# SEED Labs 2.0 — Web Server Container Dockerfile (XSS Lab)
#
# Base Image: handsonsecurity/seed-server:apache-php
#   - Contains Ubuntu Linux user space, Apache 2.4, and PHP engine.
#
# Educational Purpose:
#   - Serves the vulnerable social network application containing unsanitized profile fields.
# ==============================================================================

FROM handsonsecurity/seed-server:apache-php

# Copy social network application code into Apache document root
COPY src /var/www/html
