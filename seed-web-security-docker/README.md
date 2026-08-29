# SEED Web Security Docker Learning Environment

A Docker-Based Linux, DevOps, Web Application, and Cybersecurity Learning Environment.

For authorized educational use only. All vulnerable services run inside isolated Docker containers on your local machine.

---

## 1. Overview

This repository provides a complete, Docker-based hands-on learning environment for studying selected SEED Labs 2.0 Web Security labs without requiring VMware, VirtualBox, or a heavy pre-built SEED Virtual Machine.

Rather than treating security exercises as isolated web vulnerability tests, this environment uses a **multi-layer learning framework** where students learn systems engineering, container management, network routing, web architecture, and cybersecurity in a single unified workflow.

```
┌─────────────────────────────────────────────────────────┐
│              CYBERSECURITY LEARNING ENVIRONMENT         │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│ LAYER 1: LINUX                                          │
│ Filesystem, Processes, Users, Permissions, Networking,  │
│ Logs, Environment Variables                             │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│ LAYER 2: DOCKER                                         │
│ Images, Containers, Networks, Ports, Volumes, Compose,  │
│ Container Debugging                                     │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│ LAYER 3: WEB SECURITY LAB                               │
│ HTTP, Cookies, Sessions, Web App, Database, Flaws,      │
│ Attack Flows, Countermeasures                           │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Multi-Layer Learning Structure

The repository is structured across five interconnected learning domains:

```
Docker-Based Learning Environment
├── Linux Learning              (Shell navigation, permissions, process tables, env vars)
├── Docker Learning             (Container lifecycle, bridge networks, volumes, compose)
├── Networking Learning         (IP allocation, container DNS, host port forwarding, hosts)
├── Web Application Learning    (Apache HTTP server, PHP execution, MySQL databases)
└── Cybersecurity Learning      (SQLi, XSS, CSRF, Clickjacking, Shellshock vulnerabilities)
```

### Learning Progression Path

```
Linux Basics
     │
     ▼
Docker Basics
     │
     ▼
Container Networking
     │
     ▼
Web Application Architecture
     │
     ▼
HTTP, Cookies, and Sessions
     │
     ▼
Database Interaction
     │
     ▼
SEED Security Labs
├── 01 SQL Injection
├── 02 Cross-Site Scripting (XSS)
├── 03 Cross-Site Request Forgery (CSRF)
├── 04 Clickjacking
└── 05 Shellshock Vulnerability
```

---

## 3. Technical Clarification: Docker Container vs Full Linux VM

Docker containers provide an isolated Linux user-space environment running directly on the host OS kernel (or WSL2 Linux kernel). While containers excel at application, web server, and database experimentation, a Docker container is not a complete replacement for a full Linux virtual machine.

```
Full Virtual Machine                     Docker Container
+---------------------------------+      +---------------------------------+
| Guest Linux Kernel              |      | Host / WSL2 Linux Kernel        |
| Full OS Init (systemd)          |      |  +---------------------------+  |
| Virtual Hardware & Drivers      |      |  | Container User Space      |  |
| User Applications               |      |  | Isolated Process & Net    |  |
+---------------------------------+      |  | Application Process       |  |
                                         |  +---------------------------+  |
                                         +---------------------------------+
```

### Scope Summary

- **Docker Container CAN Teach**: Linux shell commands, filesystem navigation, process management, users and permissions, environment variables, container networking, log analysis, web server management, database administration, and web vulnerability mechanics.
- **Docker Container IS NOT Designed For**: Full OS bootloader execution, custom kernel module development (`.ko`), hardware-level device drivers, or kernel-space security research.

For detailed comparison tables and capability matrices, see [docs/container-vs-linux-vm.md](docs/container-vs-linux-vm.md).

---

## 4. Lab Compatibility Matrix

All five labs support full execution using Docker and Docker Compose. No VMware or VirtualBox is required.

| # | Lab | Docker Images | Host Access Port | Hostname Mapping |
|---|-----|--------------|------------------|------------------|
| 01 | [SQL Injection](./labs/01-sql-injection/README.md) | `seed-image-www-sqli`<br>`seed-image-mysql-sqli` | `10080` | `www.seed-server.com` |
| 02 | [XSS (Elgg)](./labs/02-xss/README.md) | `seed-image-www-xss-elgg`<br>`seed-image-mysql-xss-elgg` | `10081` | `www.seed-server.com` |
| 03 | [CSRF (Elgg)](./labs/03-csrf/README.md) | `seed-image-www-csrf-elgg`<br>`seed-image-www-csrf-attacker`<br>`seed-image-mysql-csrf` | `10082`<br>`10083` | `www.seed-server.com`<br>`www.attacker32.com` |
| 04 | [Clickjacking](./labs/04-clickjacking/README.md) | `seed-image-www-clickjacking`<br>`seed-image-www-clickjacking-attacker` | `10084`<br>`10085` | `www.cjlab.com`<br>`www.cjlab-attacker.com` |
| 05 | [Shellshock](./labs/05-shellshock/README.md) | `seed-image-www-shellshock` | `10086` | `www.seedlab-shellshock.com` |

---

## 5. Documentation Directory Index

```
seed-web-security-docker/
├── README.md                                 Main repository entry point
├── docs/
│   ├── container-vs-linux-vm.md             Technical Container vs VM comparison
│   ├── resources.md                         System hardware resource allocation guide
│   ├── common-workflow.md                   Standard 14-step operational learning flow
│   ├── troubleshooting.md                   Multi-layer 3-level diagnostic guide
│   ├── official-seed-sources.md             Official SEED URLs, citations & repositories
│   ├── docker/
│   │   ├── 01-docker-basics.md              Docker architecture & client-server model
│   │   ├── 02-images-and-containers.md      Image layers vs writable container layers
│   │   ├── 03-networks.md                   Bridge networking & container DNS
│   │   ├── 04-volumes.md                    Persistent storage & database resets
│   │   └── 05-compose.md                    Declarative compose orchestration
│   ├── linux/
│   │   ├── 01-linux-basics-in-containers.md Container shell access & identity
│   │   ├── 02-filesystem-and-navigation.md  Linux FHS hierarchy & navigation
│   │   ├── 03-users-and-permissions.md      Least privilege & permission controls
│   │   ├── 04-processes-and-services.md     PID namespaces & process inspection
│   │   ├── 05-networking-in-containers.md   Container interfaces & IP resolution
│   │   ├── 06-logs-and-debugging.md         Container stdout vs application logs
│   │   └── 07-environment-and-configuration.md Env var configuration & pass-through
│   └── platforms/
│       ├── windows-docker-desktop.md        Windows 10/11 + Docker Desktop + WSL2 setup
│       └── ubuntu-native-docker.md          Native Ubuntu Linux + Docker Engine setup
├── labs/
│   ├── 01-sql-injection/                    SQL Injection Attack Lab
│   ├── 02-xss/                              Cross-Site Scripting (XSS) Attack Lab
│   ├── 03-csrf/                             Cross-Site Request Forgery (CSRF) Lab
│   ├── 04-clickjacking/                     Clickjacking Attack Lab
│   └── 05-shellshock/                       Shellshock Vulnerability Lab
└── scripts/
    ├── check-environment.sh / .ps1          Automated environment pre-flight validation
    ├── status.sh / .ps1                     Running container & port inspector
    └── cleanup.sh / .ps1                    Safe container and image cleanup tool
```

---

## 6. Pre-flight Environment Validation

Before launching lab containers, validate host Docker engine health, RAM, disk space, and networking:

**Linux / macOS / WSL2:**
```bash
chmod +x scripts/check-environment.sh
./scripts/check-environment.sh
```

**Windows PowerShell:**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
.\scripts\check-environment.ps1
```

---

## 7. Official SEED References

- SEED Labs Project: https://seedsecuritylabs.org/
- SEED 20.04 Web Security Series: https://seedsecuritylabs.org/Labs_20.04/Web/
- SEED Official GitHub: https://github.com/seed-labs/seed-labs
- Textbook: *Computer & Internet Security: A Hands-on Approach* (2nd Ed.) by Prof. Wenliang Du
- Video Lectures: https://www.handsonsecurity.net/video.html
