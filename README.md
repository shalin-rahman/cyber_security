# Cyber Security — SEED Web Security Docker Learning Environment

A hands-on, Docker-based Linux, DevOps, Web Application, and Cybersecurity Learning Environment based on the SEED Labs 2.0 Web Security series.

For authorized educational use only. All vulnerable services run inside isolated Docker containers on your local machine.

Official SEED Labs Manuals: https://seedsecuritylabs.org/labs.html

---

## 1. Overview

This workspace provides a Docker-native implementation of five SEED Labs 2.0 Web Security labs. It eliminates the need for VMware, VirtualBox, or heavy pre-built virtual machine images by leveraging Docker Desktop and Docker Compose.

The repository follows a structured 3-Layer Learning Framework:

```
+-----------------------------------------------------------------------+
| LAYER 1: DOCKER ENGINE (HOST MACHINE)                                 |
| Image building, container lifecycle, port forwarding, networks,      |
| container resource limits, log streaming                              |
+-----------------------------------------------------------------------+
                                   |
                                   v
+-----------------------------------------------------------------------+
| LAYER 2: LINUX CONTAINER USER SPACE                                   |
| Interactive container shell (docker exec -it <container> bash),       |
| identity (whoami/id), process hierarchy (ps aux), permissions, env    |
+-----------------------------------------------------------------------+
                                   |
                                   v
+-----------------------------------------------------------------------+
| LAYER 3: SECURITY & APPLICATION LOGIC                                 |
| HTTP protocols, sessions, web application mechanics, database         |
| vulnerabilities (SQLi, XSS, CSRF, Clickjacking, Shellshock), defenses  |
+-----------------------------------------------------------------------+
```

---

## 2. Global Laboratory Index

All five security laboratories run independently using Docker Compose. Click any lab link below to open its step-by-step guide:

| Lab Directory | Security Topic | Target Domain | Host Port | Target Container | Database Container |
|---------------|----------------|---------------|-----------|------------------|--------------------|
| [`labs/01-sql-injection`](seed-web-security-docker/labs/01-sql-injection/README.md) | SQL Injection | `www.seed-server.com` | `10080` | `www-10.9.0.5` | `mysql-10.9.0.6` |
| [`labs/02-xss`](seed-web-security-docker/labs/02-xss/README.md) | Cross-Site Scripting (XSS) | `www.seed-server.com` | `10081` | `elgg-10.9.0.5` | `mysql-10.9.0.6-xss` |
| [`labs/03-csrf`](seed-web-security-docker/labs/03-csrf/README.md) | Cross-Site Request Forgery | `www.seed-server.com`<br>`www.attacker32.com` | `10082`<br>`10083` | `elgg-10.9.0.5-csrf`<br>`attacker-10.9.0.105` | `mysql-10.9.0.6-csrf` |
| [`labs/04-clickjacking`](seed-web-security-docker/labs/04-clickjacking/README.md) | Clickjacking UI Redress | `www.cjlab.com`<br>`www.cjlab-attacker.com` | `10084`<br>`10085` | `cjlab-10.9.0.80`<br>`cjlab-attacker-10.9.0.81` | N/A |
| [`labs/05-shellshock`](seed-web-security-docker/labs/05-shellshock/README.md) | Shellshock CGI (CVE-2014-6271) | `localhost` | `10086` | `shellshock-10.9.0.80` | N/A |

---

## 3. Host System Prerequisites & Environment Verification

### Requirements
- Operating System: Windows 10/11 (with Docker Desktop + WSL2 backend), Linux (Ubuntu/Debian), or macOS.
- Memory: 8 GB RAM minimum (4 GB free allocated to Docker).
- Disk Space: 10 GB free disk space.
- Virtualization: VT-x / AMD-V enabled in BIOS/UEFI.

### Pre-flight Health Check Commands

**Windows PowerShell:**
```powershell
# Verify Docker Engine and Docker Compose versions
docker version
docker compose version

# Run automated environment pre-flight validator
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
.\seed-web-security-docker\scripts\check-environment.ps1
```

**Linux / WSL2 Bash:**
```bash
# Verify Docker Engine and Docker Compose versions
docker version
docker compose version

# Run automated environment pre-flight validator
chmod +x seed-web-security-docker/scripts/check-environment.sh
./seed-web-security-docker/scripts/check-environment.sh
```

---

## 4. Hostname Configuration (Local DNS Overrides)

Several labs use domain names (`www.seed-server.com`, `www.attacker32.com`, `www.cjlab.com`, `www.cjlab-attacker.com`) to demonstrate cross-origin security properties (such as Same-Origin Policy and Cross-Site Request Forgery).

### Windows Setup (PowerShell as Administrator)
Right-click PowerShell -> "Run as administrator":

```powershell
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$entries = @(
    "10.9.0.5     www.seed-server.com",
    "10.9.0.105   www.attacker32.com",
    "10.9.0.80    www.cjlab.com",
    "10.9.0.81    www.cjlab-attacker.com"
)
foreach ($entry in $entries) {
    $hostName = ($entry -split '\s+')[1]
    if (-not (Select-String -Path $hostsFile -Pattern $hostName -Quiet)) {
        Add-Content -Path $hostsFile -Value $entry
        Write-Host "[ADDED] $entry" -ForegroundColor Green
    } else {
        Write-Host "[PRESENT] $hostName" -ForegroundColor Yellow
    }
}
```

### Linux / WSL2 Setup
```bash
sudo tee -a /etc/hosts << 'EOF'
10.9.0.5     www.seed-server.com
10.9.0.105   www.attacker32.com
10.9.0.80    www.cjlab.com
10.9.0.81    www.cjlab-attacker.com
EOF
```

---

## 5. The 3-Layer Operational Learning Sequence

Every laboratory follows a consistent 3-Layer workflow outlined in [`docs/common-workflow.md`](seed-web-security-docker/docs/common-workflow.md):

### Layer 1 — Docker Commands (Executed on Host Terminal)

Navigate to the target lab directory and run Docker lifecycle commands:

```powershell
# Example: Navigating to Lab 01 (SQL Injection)
cd seed-web-security-docker\labs\01-sql-injection

# 1. Build container images from local Dockerfiles and launch containers
docker compose up -d --build

# 2. Inspect container status and verified exposed host ports
docker compose ps

# 3. Inspect isolated container bridge network
docker network inspect net-10.9.0.0-sqli

# 4. View real-time container log output
docker compose logs -f
```

### Layer 2 — Linux Container Commands (Inside Container Shell)

**Transition to Layer 2:** Enter the running Linux web server container interactively.

```powershell
# Open interactive bash shell inside container
docker exec -it www-10.9.0.5 bash
```

*Terminal prompt changes to:* `root@www-10.9.0.5:/#`

Run internal Linux system and service diagnostics:
```bash
# 1. Verify user identity and process privileges
whoami
# Output: root

id
# Output: uid=0(root) gid=0(root) groups=0(root)

# 2. Verify container hostname and IP address
hostname
ip addr show eth0

# 3. Inspect application directory structure
cd /var/www/html
ls -la

# 4. Read vulnerable source code
cat index.php

# 5. Inspect running process tree (Apache master vs worker processes)
ps aux

# 6. Verify environment variables (e.g., database connection host)
env | grep MYSQL

# 7. Check active network listeners
ss -tlnp

# 8. View Apache web server access and error logs
tail -f /var/log/apache2/access.log
tail -f /var/log/apache2/error.log

# 9. Test connection to internal database container
mysql -h 10.9.0.6 -u root -pdees sqllab_users -e "SHOW TABLES;"

# 10. Exit container shell back to host terminal
exit
```

*Terminal prompt reverts to host PowerShell prompt:* `PS C:\...>`

### Layer 3 — Security & Application Execution

1. Perform vulnerability tasks in your host web browser:
   - Lab 01 (SQLi): `http://localhost:10080` or `http://www.seed-server.com`
   - Lab 02 (XSS): `http://localhost:10081` or `http://www.seed-server.com`
   - Lab 03 (CSRF): `http://localhost:10082` (Target) and `http://localhost:10083` (Attacker)
   - Lab 04 (Clickjacking): `http://localhost:10084` (Target) and `http://localhost:10085` (Attacker)
   - Lab 05 (Shellshock): `http://localhost:10086/cgi-bin/vul.cgi`

2. For API / Header attacks (Shellshock / SQLi via command line), use `curl.exe` in PowerShell:
   ```powershell
   # Shellshock remote code execution test
   curl.exe -A "() { :; }; echo; echo Content-Type: text/plain; echo; id" `
     http://localhost:10086/cgi-bin/vul.cgi
   ```

3. Query database state directly from host terminal:
   ```powershell
   docker exec -it mysql-10.9.0.6 mysql -u root -pdees -e "SELECT Name, Salary FROM sqllab_users.credential;"
   ```

4. Implement security countermeasures in source files and verify defense effectiveness.

5. Stop or reset the laboratory:
   ```powershell
   # Stop containers (preserves database state)
   docker compose down

   # Full reset (destroys database volumes and rebuilds clean state)
   docker compose down -v
   docker compose up -d --build
   ```

---

## 6. Workspace Documentation Map

Click any file link below to access specific learning modules, architecture diagrams, and platform guides:

```
cyber_security/
├── README.md                                                 Global root repository entry point
└── seed-web-security-docker/
    ├── README.md                                             [Primary Suite README](seed-web-security-docker/README.md)
    ├── docs/
    │   ├── common-workflow.md                                [3-Layer 14-Step Workflow](seed-web-security-docker/docs/common-workflow.md)
    │   ├── troubleshooting.md                                [3-Level Diagnostics Guide](seed-web-security-docker/docs/troubleshooting.md)
    │   ├── container-vs-linux-vm.md                          [Docker vs Linux VM Comparison](seed-web-security-docker/docs/container-vs-linux-vm.md)
    │   ├── lectures-and-references.md                        [Official References & Lecture Map](seed-web-security-docker/docs/lectures-and-references.md)
    │   ├── docker/
    │   │   ├── 01-docker-basics.md                           [Docker Core Concepts](seed-web-security-docker/docs/docker/01-docker-basics.md)
    │   │   ├── 02-images-and-containers.md                   [Image Layers & Containers](seed-web-security-docker/docs/docker/02-images-and-containers.md)
    │   │   ├── 03-networks.md                                [Bridge Networking & Host Mappings](seed-web-security-docker/docs/docker/03-networks.md)
    │   │   ├── 04-volumes.md                                 [Volume Persistence & Database Resets](seed-web-security-docker/docs/docker/04-volumes.md)
    │   │   └── 05-compose.md                             [Docker Compose Orchestration](seed-web-security-docker/docs/docker/05-compose.md)
    │   ├── linux/
    │   │   ├── 01-linux-basics-in-containers.md              [Linux Basics Inside Containers](seed-web-security-docker/docs/linux/01-linux-basics-in-containers.md)
    │   │   ├── 02-filesystem-and-navigation.md               [Filesystem & Navigation](seed-web-security-docker/docs/linux/02-filesystem-and-navigation.md)
    │   │   ├── 03-users-and-permissions.md                   [Users & Permissions](seed-web-security-docker/docs/linux/03-users-and-permissions.md)
    │   │   ├── 04-processes-and-services.md                  [Processes & Services](seed-web-security-docker/docs/linux/04-processes-and-services.md)
    │   │   ├── 05-networking-in-containers.md                [Networking in Containers](seed-web-security-docker/docs/linux/05-networking-in-containers.md)
    │   │   ├── 06-logs-and-debugging.md                      [Logs & Debugging](seed-web-security-docker/docs/linux/06-logs-and-debugging.md)
    │   │   └── 07-environment-and-configuration.md           [Environment & Configuration](seed-web-security-docker/docs/linux/07-environment-and-configuration.md)
    │   └── platforms/
    │       ├── windows-docker-desktop.md                     [Windows Docker Desktop + WSL2 Guide](seed-web-security-docker/docs/platforms/windows-docker-desktop.md)
    │       └── ubuntu-native-docker.md                       [Ubuntu Native Docker Guide](seed-web-security-docker/docs/platforms/ubuntu-native-docker.md)
    ├── labs/
    │   ├── 01-sql-injection/                                     [Lab 01: SQL Injection](seed-web-security-docker/labs/01-sql-injection/README.md)
    │   ├── 02-xss/                                               [Lab 02: Cross-Site Scripting (XSS)](seed-web-security-docker/labs/02-xss/README.md)
    │   ├── 03-csrf/                                              [Lab 03: Cross-Site Request Forgery](seed-web-security-docker/labs/03-csrf/README.md)
    │   ├── 04-clickjacking/                                      [Lab 04: Clickjacking UI Redress](seed-web-security-docker/labs/04-clickjacking/README.md)
    │   └── 05-shellshock/                                        [Lab 05: Shellshock CGI](seed-web-security-docker/labs/05-shellshock/README.md)
    └── scripts/
        ├── check-environment.ps1 / .sh                           [Environment Health Validator](seed-web-security-docker/scripts/check-environment.ps1)
        ├── status.ps1 / .sh                                      [Active Container Status Inspector](seed-web-security-docker/scripts/status.ps1)
        └── cleanup.ps1 / .sh                                     [Global Workspace Teardown Tool](seed-web-security-docker/scripts/cleanup.ps1)
```

---

## 7. Global Maintenance & Cleanup Commands

When switching labs or freeing disk space:

```powershell
# Show active running lab containers
.\seed-web-security-docker\scripts\status.ps1

# Stop all lab containers and clean lab bridge networks
.\seed-web-security-docker\scripts\cleanup.ps1

# Complete teardown including container images and build cache
.\seed-web-security-docker\scripts\cleanup.ps1 -All
```

---

## 8. Official Educational References

- SEED Security Labs Project: https://seedsecuritylabs.org/
- SEED Web Security Series: https://seedsecuritylabs.org/labs.html
- Authoritative Textbook: *Computer & Internet Security: A Hands-on Approach* (2nd Edition) by Prof. Wenliang Du
- Video Lectures: https://www.handsonsecurity.net/video.html
- Docker Documentation: https://docs.docker.com/
