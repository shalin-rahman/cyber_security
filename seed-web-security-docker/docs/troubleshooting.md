# Multi-Layer Troubleshooting and Diagnostics Guide

This document details a structured 3-level debugging methodology for diagnosing issues across Docker, Linux container user space, and web applications.

---

## 1. The 3-Level Debugging Architecture

When troubleshooting lab issues, follow this systematic resolution flow:

```
                  Problem Reported
                         |
                         v
       +-----------------------------------+
       | LEVEL 1: Docker Layer Debugging   |
       | - Is Docker Engine active?        |
       | - Are containers running?         |
       | - Are ports forwarded correctly?  |
       | - Is bridge network configured?   |
       +-----------------+-----------------+
                         | Passes
                         v
       +-----------------------------------+
       | LEVEL 2: Linux Layer Debugging    |
       | - Is the process running? (ps)    |
       | - Are permissions set? (ls -l)    |
       | - Is network bound? (ip addr)     |
       | - Are env vars set? (env)         |
       +-----------------+-----------------+
                         | Passes
                         v
       +-----------------------------------+
       | LEVEL 3: Application Debugging    |
       | - Apache logs (/var/log/apache2/) |
       | - MySQL connection health         |
       | - Browser DevTools network trace  |
       | - Code flaw verification          |
       +-----------------------------------+
```

---

## 2. Command Reference by Debugging Level

### Level 1: Docker Debugging Commands
```bash
# Check container statuses and exit codes
docker compose ps

# Inspect container stdout/stderr output
docker compose logs -f <service_name>

# Inspect bridge network assignments and container IPs
docker network inspect net-10.9.0.0-sqli
```

### Level 2: Linux Container Debugging Commands
```bash
# Enter container shell
docker exec -it <container_name> bash

# Inspect active processes inside container
ps aux

# Check user identity and permissions
whoami
id

# Check container network interface and IP
ip addr

# Check container environment variables
env
```

### Level 3: Application Debugging Commands
```bash
# Inspect Apache access log inside container
docker exec -it <container_name> tail -f /var/log/apache2/access.log

# Inspect Apache error log inside container
docker exec -it <container_name> cat /var/log/apache2/error.log

# Inspect database connection health inside container
docker exec -it mysql-10.9.0.6 mysql -u root -pdees -e "SHOW DATABASES;"
```
