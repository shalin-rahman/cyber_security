# ==============================================================================
# SEED Labs 2.0 — Web Server Container Dockerfile (SQL Injection Lab)
#
# Base Image: handsonsecurity/seed-server:apache-php
#   - Includes Ubuntu Linux user space, Apache 2.4 HTTP server, and PHP runtime.
#
# Educational Purpose:
#   - Copies the vulnerable PHP application source code into Apache's web root (/var/www/html).
#   - When the container starts, Apache reads index.php and serves HTTP requests on port 80.
# ==============================================================================

FROM handsonsecurity/seed-server:apache-php

# Copy local PHP application source code into the web server document root
COPY src /var/www/html
