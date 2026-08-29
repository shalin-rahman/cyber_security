# SEED Web Security Docker Learning Environment

Docker-first hands-on learning environment for SEED Labs 2.0 Web Security.
No VMware. No VirtualBox. No pre-built VM.

For authorized educational use only. All vulnerable services are isolated inside Docker containers on your local machine.

Official SEED Labs Project: https://seedsecuritylabs.org/labs.html

---

## 1. Overview & Architectural Positioning

This repository provides Docker-first learning environments and documentation for selected SEED Web Security labs. Each lab is validated individually against official SEED documentation to run in lightweight, locally built Docker containers.

```
LAYER 1 — LINUX CONTAINER USER SPACE
  Shell commands, filesystem, processes, users, permissions, logs

LAYER 2 — DOCKER ENGINE
  Images, containers, bridge networks, volumes, Docker Compose

LAYER 3 — WEB SECURITY
  SQL Injection, XSS, CSRF, Clickjacking, Shellshock
```

---

## 2. Hardware Resource Profiles

Run one vulnerable lab environment at a time unless testing multi-lab scenarios.

| Profile | CPU Cores | Total System RAM | Free Disk Space | Scope |
|---------|-----------|------------------|-----------------|-------|
| **Minimum** | 4 Logical Cores | 8 GB RAM | 20 GB Disk Space | Running 1 lab container set at a time |
| **Recommended** | 6–8 Cores | 16 GB RAM | 40 GB Disk Space | Active lab + VS Code + browser DevTools |
| **Advanced** | 8+ Cores | 32 GB RAM | 60+ GB SSD | Multiple lab instances + custom security tools |

---

## 3. Environment Verification (`doctor`)

Before running containers, verify host Docker health, port availability, disk space, and memory allocation:

**Windows PowerShell:**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
.\scripts\doctor.ps1
```

**Linux / WSL2 Bash:**
```bash
chmod +x scripts/doctor.sh
./scripts/doctor.sh
```

---

## 4. Labs Quick Start & Official Compatibility

Each lab is self-contained. Click a lab link to open its dedicated setup guide or compatibility specification:

### [Lab 01 — SQL Injection Attack Lab](labs/01-sql-injection/README.md) ([Official Specification](labs/01-sql-injection/OFFICIAL-COMPATIBILITY.md))

```bash
cd labs/01-sql-injection
docker compose up -d --build
docker compose ps
# Access app: http://localhost:10080 or http://www.seed-server.com
```

### [Lab 02 — XSS Attack Lab](labs/02-xss/README.md) ([Official Specification](labs/02-xss/OFFICIAL-COMPATIBILITY.md))

```bash
cd labs/02-xss
docker compose up -d --build
docker compose ps
# Access app: http://localhost:10081 or http://www.seed-server.com
```

### [Lab 03 — CSRF Attack Lab](labs/03-csrf/README.md) ([Official Specification](labs/03-csrf/OFFICIAL-COMPATIBILITY.md))

```bash
cd labs/03-csrf
docker compose up -d --build
docker compose ps
# Target site:   http://localhost:10082 or http://www.seed-server.com
# Attacker site: http://localhost:10083 or http://www.attacker32.com
```

### [Lab 04 — Clickjacking Attack Lab](labs/04-clickjacking/README.md) ([Official Specification](labs/04-clickjacking/OFFICIAL-COMPATIBILITY.md))

```bash
cd labs/04-clickjacking
docker compose up -d --build
docker compose ps
# Target site:   http://localhost:10084 or http://www.cjlab.com
# Attacker site: http://localhost:10085 or http://www.cjlab-attacker.com
```

### [Lab 05 — Shellshock Vulnerability Lab](labs/05-shellshock/README.md) ([Official Specification](labs/05-shellshock/OFFICIAL-COMPATIBILITY.md))

```bash
cd labs/05-shellshock
docker compose up -d --build
docker compose ps
# Vulnerable CGI: http://localhost:10086/cgi-bin/vul.cgi
# Safe CGI:       http://localhost:10086/cgi-bin/safe.cgi
```

---

## 5. Hostname Configuration (Local DNS Overrides)

SEED lab tasks use domain names (`www.seed-server.com`, `www.attacker32.com`, `www.cjlab.com`, `www.cjlab-attacker.com`) to test cross-origin security properties.

**Windows (PowerShell as Administrator):**

```powershell
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

## 6. Essential Docker Commands Reference

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

---

## 7. Lab Container Architecture & Port Reference

| Lab | Container Name | Host Port | Domain | Official Reference |
|-----|---------------|-----------|--------|--------------------|
| 01 SQL Injection | `www-10.9.0.5` | 10080 | `www.seed-server.com` | [Official Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Web_SQL_Injection/) |
| 02 XSS | `elgg-10.9.0.5` | 10081 | `www.seed-server.com` | [Official Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Web_XSS_Elgg/) |
| 03 CSRF | `elgg-10.9.0.5-csrf` | 10082 | `www.seed-server.com` | [Official Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Web_CSRF_Elgg/) |
| 03 CSRF | `attacker-10.9.0.105` | 10083 | `www.attacker32.com` | [Official Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Web_CSRF_Elgg/) |
| 04 Clickjacking | `cjlab-10.9.0.80` | 10084 | `www.cjlab.com` | [Official Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Web_Clickjacking/) |
| 04 Clickjacking | `cjlab-attacker-10.9.0.81` | 10085 | `www.cjlab-attacker.com` | [Official Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Web_Clickjacking/) |
| 05 Shellshock | `shellshock-10.9.0.80` | 10086 | direct IP only | [Official Manual](https://seedsecuritylabs.org/Labs_20.04/Web/Shellshock/) |

---

## 8. Resetting a Lab

If database state is altered during attack tasks:

```bash
cd labs/01-sql-injection
docker compose down -v
docker compose up -d --build
```

---

## 9. Repository Structure

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
|   +-- linux/                     Linux learning modules (01-07)
|   +-- platforms/                 Windows & Ubuntu platform guides
|
+-- labs/
|   +-- 01-sql-injection/
|   |   +-- [README.md](labs/01-sql-injection/README.md)       SQLi Lab Guide
|   |   +-- [OFFICIAL-COMPATIBILITY.md](labs/01-sql-injection/OFFICIAL-COMPATIBILITY.md) SEED Compatibility Matrix
|   +-- 02-xss/
|   |   +-- [README.md](labs/02-xss/README.md)                XSS Lab Guide
|   |   +-- [OFFICIAL-COMPATIBILITY.md](labs/02-xss/OFFICIAL-COMPATIBILITY.md) SEED Compatibility Matrix
|   +-- 03-csrf/
|   |   +-- [README.md](labs/03-csrf/README.md)               CSRF Lab Guide
|   |   +-- [OFFICIAL-COMPATIBILITY.md](labs/03-csrf/OFFICIAL-COMPATIBILITY.md) SEED Compatibility Matrix
|   +-- 04-clickjacking/
|   |   +-- [README.md](labs/04-clickjacking/README.md)       Clickjacking Lab Guide
|   |   +-- [OFFICIAL-COMPATIBILITY.md](labs/04-clickjacking/OFFICIAL-COMPATIBILITY.md) SEED Compatibility Matrix
|   +-- 05-shellshock/
|       +-- [README.md](labs/05-shellshock/README.md)          Shellshock Lab Guide
|       +-- [OFFICIAL-COMPATIBILITY.md](labs/05-shellshock/OFFICIAL-COMPATIBILITY.md) SEED Compatibility Matrix
|
+-- scripts/
    +-- [doctor.ps1](scripts/doctor.ps1) / [.sh](scripts/doctor.sh)        Environment diagnostic doctor
    +-- [check-environment.ps1](scripts/check-environment.ps1) / [.sh](scripts/check-environment.sh) Pre-flight validator
    +-- [status.ps1](scripts/status.ps1) / [.sh](scripts/status.sh)           Container status inspector
    +-- [cleanup.ps1](scripts/cleanup.ps1) / [.sh](scripts/cleanup.sh)          Workspace cleanup tool
```

---

## 10. Common Troubleshooting

See [`docs/troubleshooting.md`](docs/troubleshooting.md) for full 3-level diagnostic guide.

---

## 11. Official References

- Official SEED Lecture Sync: [SEED Lecture & Reference Sitemap](docs/lectures-and-references.md)
- SEED Security Labs Project: https://seedsecuritylabs.org/labs.html
- SEED Setup Guide: https://seedsecuritylabs.org/labsetup.html
- SEED GitHub: https://github.com/seed-labs/seed-labs
- Textbook: *Computer & Internet Security: A Hands-on Approach* (2nd Ed.) — Prof. Wenliang Du
- Video Lectures: https://www.handsonsecurity.net/video.html
- Docker Documentation: https://docs.docker.com/
