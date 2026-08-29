# Troubleshooting Guide — Docker-Based SEED Labs

This guide covers diagnostic steps for all three layers: Docker, Linux container, and application. Work through each level in order before escalating.

---

## Level 1 — Docker Layer Diagnostics

These are the first checks to run whenever anything seems broken.

### Container is not running

```bash
# Check the status of all containers defined in docker-compose.yml
docker compose ps

# Check all containers on the system (including stopped)
docker ps -a

# If STATUS shows "Exited", read why:
docker compose logs <service-name>

# Example: check why the mysql service exited
docker compose logs mysql
```

### Container keeps restarting

```bash
# Show restart count and last exit code
docker inspect <container-name> | grep -A5 '"RestartCount"'

# Follow logs in real time to catch the crash message
docker compose logs -f <service-name>
```

### Port already in use

```bash
# Windows — find what process is using port 10080
netstat -ano | findstr :10080
# Then kill it by PID: taskkill /PID <pid> /F

# Linux/WSL2 — find what is using port 10080
ss -tlnp | grep 10080
lsof -i :10080
```

### Cannot pull base image (network error)

```bash
# Test Docker Hub connectivity
docker pull hello-world

# If behind a proxy, configure Docker Desktop proxy settings
# Docker Desktop -> Settings -> Resources -> Proxies
```

### Build fails

```bash
# Run build with verbose output to see exactly which step fails
docker compose build --no-cache --progress=plain

# Try building a single service only
docker compose build www
docker compose build mysql
```

### Docker network conflict

```bash
# List all Docker networks
docker network ls

# Remove a stale lab network manually
docker network rm net-10.9.0.0-sqli

# If network is still in use:
docker network inspect net-10.9.0.0-sqli
# Find and stop the container using it, then remove the network
```

### Disk full — Docker using too much space

```bash
# Show Docker disk usage breakdown
docker system df

# Remove stopped containers, unused networks, dangling images
docker system prune

# More aggressive: also removes unused images and build cache
docker system prune -a

# WARNING — removes ALL volumes including lab databases:
docker system prune -a --volumes
```

---

## Level 2 — Linux Container Layer Diagnostics

Run these after confirming the container is running (`docker compose ps` shows "Up").

### Enter the container shell

```bash
# Open bash shell inside the container
docker exec -it www-10.9.0.5 bash

# If bash is not available, try sh
docker exec -it www-10.9.0.5 sh
```

### Check what is running inside the container

```bash
# Show all processes inside the container
ps aux

# Apache should show: /usr/sbin/apache2 -DFOREGROUND
# MySQL container should show: /usr/sbin/mysqld
```

### Check the container's network interface

```bash
# Show all network interfaces and IP addresses
ip addr show

# The eth0 interface should show the container's static IP (e.g., 10.9.0.5)

# Test connectivity to the MySQL container from the web container
ping 10.9.0.6

# Test TCP connectivity to MySQL port
curl -v telnet://10.9.0.6:3306
```

### Check file permissions

```bash
# Check who owns the web files
ls -la /var/www/html/

# Apache (www-data) must be able to read these files
# If owned by root with no read permission:
chmod -R 644 /var/www/html/
```

### Check environment variables

```bash
# List all environment variables passed to the container
env

# Key variables to verify:
# MYSQL_HOST=10.9.0.6    (web container)
# MYSQL_ROOT_PASSWORD=dees  (mysql container)
```

### Exit back to host

```bash
exit
```

---

## Level 3 — Application Layer Diagnostics

Run these after confirming the Linux environment is healthy.

### Apache web server errors

```bash
# View Apache error log (PHP errors, permission denied, bad gateway)
docker exec -it www-10.9.0.5 cat /var/log/apache2/error.log

# Stream Apache access log in real time (watch requests coming in)
docker exec -it www-10.9.0.5 tail -f /var/log/apache2/access.log

# Check Apache is actually listening on port 80
docker exec www-10.9.0.5 ss -tlnp | grep :80
```

### MySQL connection failure from web container

```bash
# Test MySQL connectivity from the web container
docker exec -it www-10.9.0.5 bash
mysql -h 10.9.0.6 -u root -pdees sqllab_users

# If connection refused: MySQL container is not running or not ready yet
# Wait 10-15 seconds after docker compose up before testing
```

### MySQL database not initialized

```bash
# Connect directly to MySQL and check if database exists
docker exec -it mysql-10.9.0.6 mysql -u root -pdees -e "SHOW DATABASES;"

# If the database is missing, the init script did not run.
# This happens if the MySQL volume already existed from a previous run.
# Fix: destroy the volume and restart
docker compose down -v
docker compose up -d --build
```

### PHP application errors in browser

```bash
# Enable PHP error display by running inside container
docker exec www-10.9.0.5 bash -c \
  "sed -i 's/display_errors = Off/display_errors = On/' /etc/php/*/apache2/php.ini && \
   service apache2 reload"

# Or check the error log directly
docker exec www-10.9.0.5 tail -50 /var/log/apache2/error.log
```

### CGI not executing (Lab 05 Shellshock)

```bash
# Verify CGI scripts are executable
docker exec shellshock-10.9.0.80 ls -la /usr/lib/cgi-bin/

# Verify Apache CGI module is enabled
docker exec shellshock-10.9.0.80 apache2ctl -M | grep cgi

# Test CGI endpoint directly
curl.exe http://localhost:10086/cgi-bin/vul.cgi
```

---

## Full Reset Procedure

When everything fails and you need to start from scratch:

```bash
# Step 1: Stop containers and remove volumes
docker compose down -v

# Step 2: Remove images built for this lab
docker rmi seed-image-www-sqli seed-image-mysql-sqli

# Step 3: Clean up any dangling resources
docker system prune

# Step 4: Rebuild from scratch
docker compose up -d --build

# Step 5: Verify
docker compose ps
docker compose logs
```
