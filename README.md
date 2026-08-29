# Cyber Security — SEED Web Security Docker Learning Environment

A hands-on, Docker-first Linux, DevOps, Web Application, and Cybersecurity Learning Environment based on the SEED Labs 2.0 Web Security series.

For authorized educational use only. All vulnerable services run inside isolated Docker containers on your local host system.

Official SEED Labs Project: https://seedsecuritylabs.org/labs.html

---

## 1. Positioning & Educational Intent

This repository provides Docker-first learning environments and comprehensive documentation for selected SEED Web Security labs. Each lab is validated individually against official SEED documentation to run in lightweight, locally built Docker containers without requiring VirtualBox, VMware, or heavy pre-built virtual machines.

The environment follows a structured 3-Layer Learning Framework:

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

## 2. Global Laboratory Index & Compatibility Matrix

All five security laboratories run independently using Docker Compose.

| Lab Module | Security Topic | Official SEED Reference | Docker Build | Browser / Client | Host Domain Mapping | Compatibility & Status |
|------------|----------------|-------------------------|--------------|------------------|---------------------|------------------------|
| [`labs/01-sql-injection`](seed-web-security-docker/labs/01-sql-injection/README.md) | SQL Injection | [SEED SQLi Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Web_SQL_Injection/) | Local Dockerfiles | Web Browser | `www.seed-server.com` | [Environment Validated](seed-web-security-docker/labs/01-sql-injection/OFFICIAL-COMPATIBILITY.md) |
| [`labs/02-xss`](seed-web-security-docker/labs/02-xss/README.md) | Cross-Site Scripting | [SEED XSS Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Web_XSS_Elgg/) | Local Dockerfiles | Web Browser | `www.seed-server.com` | [Environment Validated](seed-web-security-docker/labs/02-xss/OFFICIAL-COMPATIBILITY.md) |
| [`labs/03-csrf`](seed-web-security-docker/labs/03-csrf/README.md) | Cross-Site Request Forgery | [SEED CSRF Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Web_CSRF_Elgg/) | Local Dockerfiles | Web Browser (Dual Origin) | `www.seed-server.com`<br>`www.attacker32.com` | [Environment Validated](seed-web-security-docker/labs/03-csrf/OFFICIAL-COMPATIBILITY.md) |
| [`labs/04-clickjacking`](seed-web-security-docker/labs/04-clickjacking/README.md) | Clickjacking UI Redress | [SEED Clickjacking Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Web_Clickjacking/) | Local Dockerfiles | Web Browser + DevTools | `www.cjlab.com`<br>`www.cjlab-attacker.com` | [Environment Validated](seed-web-security-docker/labs/04-clickjacking/OFFICIAL-COMPATIBILITY.md) |
| [`labs/05-shellshock`](seed-web-security-docker/labs/05-shellshock/README.md) | Shellshock CGI (CVE-2014-6271) | [SEED Shellshock Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Shellshock/) | Local Dockerfiles | `curl.exe` / Web Browser | Direct CGI Endpoint (`:10086`) | [Environment Validated](seed-web-security-docker/labs/05-shellshock/OFFICIAL-COMPATIBILITY.md) |

---

## 3. Host System Hardware Profiles & Requirements

Run one vulnerable laboratory environment at a time unless testing multi-lab scenarios.

| Resource Profile | CPU Cores | Total System RAM | Free Disk Space | Operational Scope |
|------------------|-----------|------------------|-----------------|-------------------|
| **Minimum** | 4 Logical Cores | 8 GB RAM | 20 GB Disk Space | Running 1 lab container set at a time |
| **Recommended** | 6–8 Cores | 16 GB RAM | 40 GB Disk Space | Active lab + VS Code + browser DevTools |
| **Advanced** | 8+ Cores | 32 GB RAM | 60+ GB SSD | Multiple lab instances + custom security tooling |

---

## 4. System Environment Health Verification (`doctor`)

Before launching containers, run the interactive environment diagnostic doctor script to verify Docker daemon liveness, port availability, disk space, and memory allocation.

**Windows PowerShell:**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
.\seed-web-security-docker\scripts\doctor.ps1
```

**Linux / WSL2 Bash:**
```bash
chmod +x seed-web-security-docker/scripts/doctor.sh
./seed-web-security-docker/scripts/doctor.sh
```

---

## 5. Hostname Configuration (Local DNS Overrides)

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

## 6. The 3-Layer Operational Learning Sequence

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

## 7. Workspace Repository Architecture

```
cyber_security/
├── README.md                                                 Global root repository entry point
├── LICENSE                                                   [MIT Open Source License](LICENSE)
├── SECURITY.md                                               [Security Policy & Scope](SECURITY.md)
├── CODE_OF_CONDUCT.md                                        [Community Code of Conduct](CODE_OF_CONDUCT.md)
├── CONTRIBUTING.md                                           [Contribution Guidelines](CONTRIBUTING.md)
├── CHANGELOG.md                                              [Project Release History](CHANGELOG.md)
├── .github/workflows/
│   ├── markdown-validation.yml                               [Markdown Validation CI](.github/workflows/markdown-validation.yml)
│   └── docker-validation.yml                                 [Docker Compose CI](.github/workflows/docker-validation.yml)
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
    │   ├── 01-sql-injection/                                     [Lab 01: SQL Injection Guide](seed-web-security-docker/labs/01-sql-injection/README.md)
    │   │   └── OFFICIAL-COMPATIBILITY.md                        [Lab 01 Specification & Compatibility](seed-web-security-docker/labs/01-sql-injection/OFFICIAL-COMPATIBILITY.md)
    │   ├── 02-xss/                                               [Lab 02: Cross-Site Scripting Guide](seed-web-security-docker/labs/02-xss/README.md)
    │   │   └── OFFICIAL-COMPATIBILITY.md                        [Lab 02 Specification & Compatibility](seed-web-security-docker/labs/02-xss/OFFICIAL-COMPATIBILITY.md)
    │   ├── 03-csrf/                                              [Lab 03: CSRF Guide](seed-web-security-docker/labs/03-csrf/README.md)
    │   │   └── OFFICIAL-COMPATIBILITY.md                        [Lab 03 Specification & Compatibility](seed-web-security-docker/labs/03-csrf/OFFICIAL-COMPATIBILITY.md)
    │   ├── 04-clickjacking/                                      [Lab 04: Clickjacking UI Redress Guide](seed-web-security-docker/labs/04-clickjacking/README.md)
    │   │   └── OFFICIAL-COMPATIBILITY.md                        [Lab 04 Specification & Compatibility](seed-web-security-docker/labs/04-clickjacking/OFFICIAL-COMPATIBILITY.md)
    │   └── 05-shellshock/                                        [Lab 05: Shellshock CGI Guide](seed-web-security-docker/labs/05-shellshock/README.md)
    │       └── OFFICIAL-COMPATIBILITY.md                        [Lab 05 Specification & Compatibility](seed-web-security-docker/labs/05-shellshock/OFFICIAL-COMPATIBILITY.md)
    └── scripts/
        ├── doctor.ps1 / .sh                                      [Environment Doctor & Diagnostic Tool](seed-web-security-docker/scripts/doctor.ps1)
        ├── check-environment.ps1 / .sh                           [Pre-flight Environment Health Check](seed-web-security-docker/scripts/check-environment.ps1)
        ├── status.ps1 / .sh                                      [Active Container Status Inspector](seed-web-security-docker/scripts/status.ps1)
        └── cleanup.ps1 / .sh                                     [Global Workspace Teardown Tool](seed-web-security-docker/scripts/cleanup.ps1)
```

---

## 8. Global Maintenance & Diagnostics Commands

```powershell
# Run environment doctor diagnostic tool
.\seed-web-security-docker\scripts\doctor.ps1

# Show active running lab containers
.\seed-web-security-docker\scripts\status.ps1

# Stop all lab containers and clean lab bridge networks
.\seed-web-security-docker\scripts\cleanup.ps1

# Complete teardown including container images and build cache
.\seed-web-security-docker\scripts\cleanup.ps1 -All
```

---

## 9. Official Educational References

- Official SEED Lecture Sync: [SEED Lecture & Reference Sitemap](seed-web-security-docker/docs/lectures-and-references.md)
- SEED Security Labs Project: https://seedsecuritylabs.org/
- SEED Web Security Series: https://seedsecuritylabs.org/labs.html
- Authoritative Textbook: *Computer & Internet Security: A Hands-on Approach* (2nd Edition) by Prof. Wenliang Du
- Video Lectures: https://www.handsonsecurity.net/video.html
- Docker Documentation: https://docs.docker.com/
