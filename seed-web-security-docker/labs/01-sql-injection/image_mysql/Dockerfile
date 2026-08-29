# ==============================================================================
# SEED Labs 2.0 — Database Container Dockerfile (SQL Injection Lab)
#
# Base Image: mysql:8.0
#   - Standard MySQL 8.0 database engine image.
#
# Educational Purpose:
#   - Automatically initializes the 'sqllab_users' database and populates the 'credential' table.
#   - MySQL automatically executes any .sql scripts placed in /docker-entrypoint-initdb.d/ on first launch.
# ==============================================================================

FROM mysql:8.0

# Set default MySQL root password to 'dees' (matches SEED lab manual specifications)
ENV MYSQL_ROOT_PASSWORD=dees

# Copy SQL initialization script into MySQL auto-execution directory
COPY sqllab_users.sql /docker-entrypoint-initdb.d/
