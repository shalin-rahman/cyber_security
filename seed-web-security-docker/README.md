# SEED Web Security Docker Learning Environment

Docker-based hands-on learning environment for SEED Labs 2.0 Web Security.
No VMware. No VirtualBox. No pre-built VM.

For authorized educational use only. All vulnerable services are isolated inside Docker containers on your local machine.

Official SEED Labs: https://seedsecuritylabs.org/labs.html

---

## Overview

This repository implements five SEED Labs 2.0 Web Security labs entirely inside Docker containers. Each lab teaches three things at once: Linux systems knowledge, Docker container operations, and web security vulnerability mechanics.

```
LAYER 1 — LINUX
  Shell commands, filesystem, processes, users, permissions, logs

LAYER 2 — DOCKER
  Images, containers, networks, volumes, Docker Compose

LAYER 3 — WEB SECURITY
  SQL Injection, XSS, CSRF, Clickjacking, Shellshock
```

---

## Requirements

- Docker Desktop (Windows/macOS) or Docker Engine (Linux)
- Docker Compose (included with Docker Desktop)
- 4 GB RAM free minimum (8 GB recommended)
- 10 GB free disk space

**Verify your setup before starting:**

```bash
# Check Docker is installed and daemon is running
docker version

# Check Docker Compose is available
docker compose version

# Check available disk space
docker system df
```

---

## Labs Quick Start

Each lab is self-contained. Click any lab link below to open its dedicated lab guide.

### [Lab 01 — SQL Injection Attack Lab](labs/01-sql-injection/README.md)

```bash
cd labs/01-sql-injection

# Build images from local Dockerfiles and start containers
docker compose up -d --build

# Verify both containers are running
docker compose ps

# Access the vulnerable app
# http://localhost:10080
```

### [Lab 02 — XSS Attack Lab](labs/02-xss/README.md)

```bash
cd labs/02-xss
docker compose up -d --build
docker compose ps
# http://localhost:10081
```

### [Lab 03 — CSRF Attack Lab](labs/03-csrf/README.md)

```bash
cd labs/03-csrf
docker compose up -d --build
docker compose ps
# Target site:   http://localhost:10082
# Attacker site: http://localhost:10083
```

### [Lab 04 — Clickjacking Attack Lab](labs/04-clickjacking/README.md)

```bash
cd labs/04-clickjacking
docker compose up -d --build
docker compose ps
# Target site:   http://localhost:10084
# Attacker site: http://localhost:10085
```

### [Lab 05 — Shellshock Vulnerability Lab](labs/05-shellshock/README.md)

```bash
cd labs/05-shellshock
docker compose up -d --build
docker compose ps
# Vulnerable CGI: http://localhost:10086/cgi-bin/vul.cgi
# Safe CGI:       http://localhost:10086/cgi-bin/safe.cgi
```

---

## Hostname Configuration (Optional but Recommended)

SEED lab tasks and screenshots use domain names instead of localhost ports.
Add these entries to your hosts file so the domains resolve to container IPs.

**Windows** — Open PowerShell as Administrator:

```powershell
# Add all lab hostnames at once
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$entries = @(
    "10.9.0.5     www.seed-server.com",
    "10.9.0.105   www.attacker32.com",
    "10.9.0.80    www.cjlab.com",
    "10.9.0.81    www.cjlab-attacker.com"
)
foreach ($entry in $entries) {
    Add-Content -Path $hostsFile -Value $entry
}
```

**Linux / WSL2:**

```bash
sudo tee -a /etc/hosts << 'EOF'
10.9.0.5     www.seed-server.com
10.9.0.105   www.attacker32.com
10.9.0.80    www.cjlab.com
10.9.0.81    www.cjlab-attacker.com
EOF
```

---

## Essential Docker Commands Reference

These commands are used throughout all labs. Learn them once, apply everywhere.

### Container Lifecycle

```bash
# Build images and start all services in background
docker compose up -d --build

# Start without rebuilding (uses existing images)
docker compose up -d

# Stop containers (preserves database volumes)
docker compose down

# Stop AND delete all data volumes (full reset)
docker compose down -v

# Show running containers with ports and status
docker compose ps

# Show container resource usage (CPU, RAM, network)
docker stats
```

### Entering a Container Shell

```bash
# Open an interactive bash shell inside a running container
docker exec -it <container-name> bash

# Example: enter the web server container in Lab 01
docker exec -it www-10.9.0.5 bash

# Example: enter the MySQL container in Lab 01
docker exec -it mysql-10.9.0.6 bash
```

### Inspecting Running Containers

```bash
# List all running containers (name, image, ports, status)
docker ps

# Show detailed container configuration (IP, network, mounts, env vars)
docker inspect <container-name>

# Show container IP address specifically
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container-name>

# Show real-time logs from a container
docker logs -f <container-name>

# Show last 50 lines of logs
docker logs --tail 50 <container-name>
```

### Linux Inspection Inside Containers

Once inside a container shell (`docker exec -it <name> bash`):

```bash
# Who am I running as?
whoami
id

# What is this container's hostname?
hostname

# What is this container's IP address?
ip addr show
# or: hostname -I

# What processes are running?
ps aux

# What is the web server serving?
ls -la /var/www/html/

# View Apache access logs
cat /var/log/apache2/access.log
tail -f /var/log/apache2/error.log

# View environment variables (check MYSQL_HOST, passwords)
env

# Check disk usage
df -h

# Check open network connections
ss -tlnp
```

### Database Access

```bash
# Connect to MySQL inside the database container
docker exec -it mysql-10.9.0.6 mysql -u root -pdees sqllab_users

# Or connect from the web container to MySQL at 10.9.0.6
docker exec -it www-10.9.0.5 bash
# Inside: mysql -h 10.9.0.6 -u root -pdees sqllab_users

# Inside MySQL shell — useful commands
SHOW DATABASES;
USE sqllab_users;
SHOW TABLES;
DESCRIBE credential;
SELECT * FROM credential;
```

### Image and Cleanup Management

```bash
# List all locally built images
docker images

# Remove a specific image (force rebuild next time)
docker rmi seed-image-www-sqli

# Remove all stopped containers, unused networks, dangling images
docker system prune

# Remove everything including volumes (WARNING: deletes all lab data)
docker system prune -a --volumes

# Check how much disk Docker is using
docker system df
```

---

## Lab Container Architecture

Each lab runs on an isolated Docker bridge network (`10.9.0.0/24`).
Containers have fixed IPs. The host machine connects via mapped ports.

```
HOST MACHINE (Windows / Linux / macOS)
  |
  |  Port 10080 -> www-10.9.0.5:80    (Lab 01 web server)
  |  Port 10081 -> elgg-10.9.0.5:80   (Lab 02 web server)
  |  Port 10082 -> elgg-10.9.0.5:80   (Lab 03 target site)
  |  Port 10083 -> attacker:80         (Lab 03 attacker site)
  |  Port 10084 -> cjlab:80            (Lab 04 target site)
  |  Port 10085 -> cjlab-attacker:80   (Lab 04 attacker site)
  |  Port 10086 -> shellshock:80       (Lab 05 CGI server)
  |
  Docker bridge network (10.9.0.0/24)
    |
    +-- 10.9.0.5   www container    (Apache + PHP)
    +-- 10.9.0.6   mysql container  (MySQL 8.0)
    +-- 10.9.0.105 attacker         (Apache static site)
```

---

## Lab Port and Hostname Reference

| Lab | Container Name | Host Port | Domain | Official Lab Page |
|-----|---------------|-----------|--------|-------------------|
| 01 SQL Injection | `www-10.9.0.5` | 10080 | `www.seed-server.com` | [Official Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Web_SQL_Injection/) |
| 02 XSS | `elgg-10.9.0.5` | 10081 | `www.seed-server.com` | [Official Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Web_XSS_Elgg/) |
| 03 CSRF | `elgg-10.9.0.5-csrf` | 10082 | `www.seed-server.com` | [Official Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Web_CSRF_Elgg/) |
| 03 CSRF | `attacker-10.9.0.105` | 10083 | `www.attacker32.com` | [Official Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Web_CSRF_Elgg/) |
| 04 Clickjacking | `cjlab-10.9.0.80` | 10084 | `www.cjlab.com` | [Official Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Web_Clickjacking/) |
| 04 Clickjacking | `cjlab-attacker-10.9.0.81` | 10085 | `www.cjlab-attacker.com` | [Official Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Web_Clickjacking/) |
| 05 Shellshock | `shellshock-10.9.0.80` | 10086 | direct IP only | [Official Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Shellshock/) |

---

## Reset a Lab

If the database gets corrupted or you want to redo tasks from a clean state:

```bash
cd labs/01-sql-injection   # (or whichever lab)

# Destroy containers AND volumes, then rebuild from scratch
docker compose down -v
docker compose up -d --build
```

This wipes the database volume and re-runs the `.sql` init script, restoring original data.

---

## Repository Structure

```
seed-web-security-docker/
|
+-- README.md                       This file — start here
|
+-- docs/
|   +-- [container-vs-linux-vm.md](docs/container-vs-linux-vm.md)   Why Docker instead of VM, and limitations
|   +-- [common-workflow.md](docs/common-workflow.md)         Standard 14-step 3-layer lab workflow
|   +-- [troubleshooting.md](docs/troubleshooting.md)         Docker diagnostic commands
|   +-- [lectures-and-references.md](docs/lectures-and-references.md) Official SEED + OWASP + CVE references
|   +-- docker/                    Docker learning modules (01-05)
|   |   +-- [01-docker-basics.md](docs/docker/01-docker-basics.md)
|   |   +-- [03-networks.md](docs/docker/03-networks.md)
|   |   +-- [05-compose.md](docs/docker/05-compose.md)
|   +-- linux/                     Linux learning modules (01-07)
|   |   +-- [01-linux-basics-in-containers.md](docs/linux/01-linux-basics-in-containers.md)
|   +-- platforms/
|       +-- [windows-docker-desktop.md](docs/platforms/windows-docker-desktop.md) Windows + WSL2 setup guide
|       +-- [ubuntu-native-docker.md](docs/platforms/ubuntu-native-docker.md)     Ubuntu Linux setup guide
|
+-- labs/
|   +-- 01-sql-injection/
|   |   +-- [README.md](labs/01-sql-injection/README.md)       SQLi Lab Guide
|   +-- 02-xss/
|   |   +-- [README.md](labs/02-xss/README.md)                XSS Lab Guide
|   +-- 03-csrf/
|   |   +-- [README.md](labs/03-csrf/README.md)               CSRF Lab Guide
|   +-- 04-clickjacking/
|   |   +-- [README.md](labs/04-clickjacking/README.md)       Clickjacking Lab Guide
|   +-- 05-shellshock/
|       +-- [README.md](labs/05-shellshock/README.md)          Shellshock Lab Guide
|
+-- scripts/
    +-- [check-environment.ps1](scripts/check-environment.ps1) / [.sh](scripts/check-environment.sh)  Pre-flight validator
    +-- [status.ps1](scripts/status.ps1) / [.sh](scripts/status.sh)             Show all running lab containers
    +-- [cleanup.ps1](scripts/cleanup.ps1) / [.sh](scripts/cleanup.sh)            Remove stopped containers and images
```

---

## Common Troubleshooting

See [`docs/troubleshooting.md`](docs/troubleshooting.md) for full 3-level diagnostic guide.

**Container exits immediately:**
```bash
# Check why it stopped
docker compose logs <service-name>
docker logs <container-name>
```

**Port already in use:**
```bash
# Find what is using the port
netstat -ano | findstr :10080       # Windows
ss -tlnp | grep 10080               # Linux

# Stop conflicting lab first
docker compose down
```

**Cannot connect to MySQL from web container:**
```bash
# Enter web container and test connection manually
docker exec -it www-10.9.0.5 bash
mysql -h 10.9.0.6 -u root -pdees sqllab_users

# Check MySQL container is running
docker compose ps
docker logs mysql-10.9.0.6
```

**Build fails (Dockerfile error):**
```bash
# Run build with verbose output
docker compose build --no-cache --progress=plain
```

**Reset everything and start fresh:**
```bash
docker compose down -v
docker system prune
docker compose up -d --build
```

---

## Official References

- SEED Labs Project: https://seedsecuritylabs.org/labs.html
- SEED Setup Guide: https://seedsecuritylabs.org/labsetup.html
- SEED GitHub: https://github.com/seed-labs/seed-labs
- Textbook: *Computer & Internet Security: A Hands-on Approach* — Prof. Wenliang Du
- Video Lectures: https://www.handsonsecurity.net/video.html
- Docker Documentation: https://docs.docker.com/
