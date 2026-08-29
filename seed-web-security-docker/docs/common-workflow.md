# Common Lab Workflow — 3-Layer Learning Sequence

Every lab in this repository follows the same 3-layer structure. You work through all three layers for each lab. The layers build on each other — Layer 1 is the foundation.

---

## The 3 Layers

```
LAYER 1 — DOCKER (host machine)
  You stay on your host terminal.
  You manage containers: build, start, inspect, stop.
  Commands: docker compose, docker inspect, docker logs

LAYER 2 — LINUX (inside the container)
  You enter the container using 'docker exec -it <name> bash'.
  You are now inside an isolated Linux environment.
  Commands: pwd, ls, ps aux, whoami, ip addr, cat, env

LAYER 3 — SECURITY (browser + terminal)
  You perform the actual attack tasks.
  You use your browser, curl, and MySQL to trigger and observe the vulnerability.
  You then implement the countermeasure and verify it stops the attack.
```

The transition between layers is always explicit. You know exactly when you are on the host versus inside a container.

---

## Layer 1 — Docker Commands (run on your host terminal)

### Step 1.1 — Understand the Lab Architecture

Before running anything, read the compose file to understand what will be created:

```bash
# View the container definitions, IPs, ports, and networks
cat docker-compose.yml
```

Key things to note in the compose file:
- How many services (containers) are defined
- What static IP each container gets (`ipv4_address`)
- What host port maps to which container (`ports`)
- Which service starts first (`depends_on`)

---

### Step 1.2 — Build Images and Start Containers

```bash
# Build Docker images from local Dockerfiles and start all containers
# '--build' rebuilds images if source files changed
# '-d' runs containers in background (detached mode)
docker compose up -d --build

# What happens behind the scenes:
# 1. Docker reads docker-compose.yml
# 2. Builds image_www/Dockerfile  -> creates Apache+PHP image with vulnerable app
# 3. Builds image_mysql/Dockerfile -> creates MySQL image with pre-loaded database
# 4. Creates an isolated bridge network (10.9.0.0/24)
# 5. Starts containers with fixed static IPs
# 6. Maps host ports (e.g., 10080 on host -> 80 inside container)
```

---

### Step 1.3 — Verify Containers Are Running

```bash
# Show status of all containers defined in this compose file
docker compose ps

# Expected output:
# NAME             IMAGE                   STATUS    PORTS
# www-10.9.0.5     seed-image-www-sqli     Up        0.0.0.0:10080->80/tcp
# mysql-10.9.0.6   seed-image-mysql-sqli   Up        3306/tcp

# Check all containers on the system (including from other labs)
docker ps

# Check CPU and memory usage per container
docker stats --no-stream
```

---

### Step 1.4 — Inspect the Docker Network

```bash
# List all Docker networks (find the lab network)
docker network ls

# Inspect the lab network — shows subnet, gateway, connected containers and their IPs
docker network inspect net-10.9.0.0-sqli

# Confirm each container's assigned IP
docker inspect -f '{{.Name}} -> {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
  www-10.9.0.5 mysql-10.9.0.6
```

---

### Step 1.5 — View Container Logs from Host

```bash
# View all container logs (stdout/stderr captured by Docker)
docker compose logs

# Stream logs in real time — watch requests arriving as you use the browser
docker compose logs -f

# Stream logs for one service only
docker compose logs -f www
docker compose logs -f mysql

# Show last 50 lines only
docker compose logs --tail 50 www
```

---

## Layer 2 — Linux Commands (inside the container shell)

### Step 2.1 — Open a Bash Shell Inside the Container

**This is the key transition step. You leave your host terminal and enter the container's Linux environment.**

```bash
# Open an interactive bash shell inside the web server container
docker exec -it www-10.9.0.5 bash
```

Your terminal prompt changes. You are now inside the container:
```
Before: PS C:\Users\YourName>          (Windows host)
After:  root@www-10.9.0.5:/#           (inside Linux container)
```

On Linux/macOS:
```
Before: user@hostname:~$               (Linux/macOS host)
After:  root@www-10.9.0.5:/#           (inside Linux container)
```

---

### Step 2.2 — Establish Identity and Context

Run these immediately after entering to orient yourself:

```bash
# Who is this process running as?
whoami
# Output: root

# Show user ID, group ID, supplementary groups
id
# Output: uid=0(root) gid=0(root) groups=0(root)

# What is this container's hostname?
hostname
# Output: www-10.9.0.5

# What is this container's IP address on the Docker network?
ip addr show
# Look for the eth0 interface showing 10.9.0.5/24
```

---

### Step 2.3 — Inspect the Application Files

```bash
# Navigate to the web server document root
cd /var/www/html

# List all application files
ls -la
# You will see: index.php (the vulnerable web application)

# Read the vulnerable application source code
cat index.php

# Search for the vulnerable SQL query construction line
grep -n "SELECT" index.php
grep -n "password" index.php

# View the Apache configuration
cat /etc/apache2/sites-enabled/000-default.conf

# Apache's document root is /var/www/html
# All .php files here are served by Apache when a browser requests them
```

---

### Step 2.4 — Inspect Processes and Services

```bash
# Show all running processes inside the container
ps aux

# You should see:
# apache2 (master process, runs as root)
# apache2 (worker processes, run as www-data — unprivileged user)
# This separation is a security design: workers run with minimal privilege

# Check what port Apache is listening on
ss -tlnp
# Should show: 0.0.0.0:80

# Check open network connections
ss -tnp
```

---

### Step 2.5 — Inspect Environment Variables

```bash
# Show all environment variables passed from docker-compose.yml
env

# Key variables:
# MYSQL_HOST=10.9.0.6   <- tells PHP where the database container is
# This is why the PHP code uses: getenv('MYSQL_HOST') instead of 'localhost'

# Show a specific variable
echo $MYSQL_HOST
```

---

### Step 2.6 — Test Connectivity to the Database Container

```bash
# Test if the database container is reachable from inside the web container
ping 10.9.0.6

# Try connecting to MySQL from inside the web container
mysql -h 10.9.0.6 -u root -pdees sqllab_users

# Inside MySQL:
SHOW TABLES;
DESCRIBE credential;
SELECT Name, Salary FROM credential;
EXIT;
```

---

### Step 2.7 — Inspect Application Logs Inside Container

```bash
# Real-time Apache access log (watch HTTP requests arrive as you browse)
tail -f /var/log/apache2/access.log

# Apache error log (PHP errors, connection failures)
cat /var/log/apache2/error.log
```

---

### Step 2.8 — Exit the Container Shell Back to Host

```bash
# Return to your host terminal
exit
```

Your prompt returns to normal:
```
Before: root@www-10.9.0.5:/#    (inside container)
After:  PS C:\Users\YourName>   (back on Windows host)
```

---

## Layer 3 — Security Tasks (browser + host terminal)

### Step 3.1 — Access the Vulnerable Application

Open your browser:

```
http://localhost:10080               always works (direct port mapping)
http://www.seed-server.com           works if hosts file is configured
```

To configure the hosts file (Windows — run PowerShell as Administrator):
```powershell
Add-Content "C:\Windows\System32\drivers\etc\hosts" "10.9.0.5   www.seed-server.com"
```

Linux/WSL2:
```bash
echo "10.9.0.5   www.seed-server.com" | sudo tee -a /etc/hosts
```

---

### Step 3.2 — Perform the Attack Tasks

Follow the official SEED lab manual tasks. Each lab has specific tasks in its own `README.md`.

Example for Lab 01 SQL Injection:

```
Task 2.1: In the Login form, enter:
  Username: admin'#
  Password: anything

The # starts an SQL comment — everything after it (the password check) is ignored.
```

After performing an attack in the browser, check the database to see what changed:

```bash
# From your host terminal — check database state without entering container
docker exec -it mysql-10.9.0.6 mysql -u root -pdees \
  -e "SELECT Name, Salary FROM sqllab_users.credential;"
```

---

### Step 3.3 — Observe the Attack in Apache Logs

```bash
# From host — stream Apache access log while performing attacks in browser
docker exec -it www-10.9.0.5 tail -f /var/log/apache2/access.log

# Each HTTP request shows:
# [IP] [timestamp] "GET/POST /path HTTP/1.1" [status code] [bytes]
```

---

### Step 3.4 — Study the Root Cause (Vulnerable Code)

```bash
# Extract the vulnerable PHP file to your host for closer inspection
docker cp www-10.9.0.5:/var/www/html/index.php ./index_original.php

# Open it in your editor and find the unsafe string concatenation
```

---

### Step 3.5 — Implement the Countermeasure

Edit the PHP source on your host, then copy it back into the running container:

```bash
# Copy modified file into the container (takes effect immediately, no rebuild)
docker cp ./index.php www-10.9.0.5:/var/www/html/index.php

# Verify the change
docker exec www-10.9.0.5 cat /var/www/html/index.php
```

Test the same attack payload again in the browser. Confirm it no longer works.

---

### Step 3.6 — Stop or Reset the Lab

```bash
# Stop containers, preserve database (resume later with 'docker compose up -d')
docker compose down

# Full wipe — destroy database volumes, rebuild from original SQL init script
docker compose down -v
docker compose up -d --build
```

---

## Quick Layer Reference Card

| Layer | Where You Are | How to Get There | How to Leave |
|-------|--------------|-----------------|-------------|
| Layer 1 — Docker | Host terminal | Already here at start | (no change) |
| Layer 2 — Linux | Inside container | `docker exec -it <container> bash` | `exit` |
| Layer 3 — Security | Browser + host terminal | `exit` from container, open browser | `docker compose down` |

---

## Layer 2 — Entering Each Container

| Container | Purpose | Open Bash Command |
|-----------|---------|-------------------|
| `www-10.9.0.5` | Web server (Apache + PHP) | `docker exec -it www-10.9.0.5 bash` |
| `mysql-10.9.0.6` | Database (MySQL) | `docker exec -it mysql-10.9.0.6 bash` |
| `elgg-10.9.0.5` | XSS/CSRF social network | `docker exec -it elgg-10.9.0.5 bash` |
| `attacker-10.9.0.105` | CSRF attacker site | `docker exec -it attacker-10.9.0.105 bash` |
| `cjlab-10.9.0.80` | Clickjacking target | `docker exec -it cjlab-10.9.0.80 bash` |
| `cjlab-attacker-10.9.0.81` | Clickjacking attacker | `docker exec -it cjlab-attacker-10.9.0.81 bash` |
| `shellshock-10.9.0.80` | Shellshock CGI server | `docker exec -it shellshock-10.9.0.80 bash` |
