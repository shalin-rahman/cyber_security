# Lab 02 — Official SEED Compatibility Matrix & Specification

**Implementation Type**: Official SEED source adapted for Docker

This document explicitly separates the **Official SEED Lab Environment Specification** from the **Extended Learning Layer** provided in this repository.

---

## 1. Official SEED Specification

- **Official SEED Lab Title**: Cross-Site Scripting (XSS) Attack Lab (Elgg)
- **Official SEED Manual URL**: https://seedsecuritylabs.org/Labs_20.04/Web/Web_XSS_Elgg/
- **Textbook Correlation**: Chapter 11 — Cross-Site Scripting Attack (*Computer & Internet Security*, 2nd Ed., Prof. Wenliang Du)
- **Official Image Dependencies**: `handsonsecurity/seed-server:apache-php`, `handsonsecurity/seed-image-mysql-xss-elgg`
- **Official Network Topology**: Two-container architecture on bridge network `10.9.0.0/24`:
  - `10.9.0.5` -> Apache + PHP Elgg Social Network
  - `10.9.0.6` -> MySQL 8.0 containing `elgg` database and default profiles (`alice`, `samy`, `boby`)

---

## 2. Host Browser vs. Docker Container Network Architecture

```
HOST BROWSER (Windows / Linux / macOS)
    |
    | Connects to: http://localhost:10081  OR  http://www.seed-server.com:10081
    v
HOST NETWORK STACK (127.0.0.1 / localhost)
    |
    | Port Forwarding Rule: Host Port 10081 -> Container Port 80
    v
DOCKER ENGINE / WSL2 VM BRIDGE
    |
    | Virtual Bridge Interface: net-10.9.0.0-xss (Subnet 10.9.0.0/24)
    v
CONTAINER USER SPACE
    |-- 10.9.0.5 (elgg-10.9.0.5 container IP — internal container-to-container routing)
    |-- 10.9.0.6 (mysql-10.9.0.6-xss container IP — internal database storage)
```

> **IMPORTANT HOST ROUTING NOTICE**:  
> Do **not** map `10.9.0.5 www.seed-server.com` directly in your host `/etc/hosts` file when running Docker Desktop on Windows or macOS. Docker Desktop runs inside a lightweight WSL2 / Hyper-V VM where internal container IPs (`10.9.0.5`) are not routable from the host OS network adapter.  
>  
> To access the lab via domain name on host browsers, map `127.0.0.1 www.seed-server.com` in hosts, then visit `http://www.seed-server.com:10081` in your browser.

---

## 3. Environment Compatibility & Validation Matrix

| Feature | Official SEED Environment | Local Docker Learning Environment | Precise Validation Status |
|---------|---------------------------|-----------------------------------|---------------------------|
| Application Framework | Elgg Social Network Platform | Built locally via `image_www/Dockerfile` | `BUILD-VALIDATED` |
| Database Engine | MySQL 8.0 (`elgg` schema) | Built locally via `image_mysql/Dockerfile` | `BUILD-VALIDATED` |
| Container Lifecycle | `docker compose up -d` | Verified via `docker compose ps` | `RUNTIME-VALIDATED` |
| Bridge Network Isolation | `10.9.0.0/24` subnet | Assigned in `docker-compose.yml` (`net-10.9.0.0-xss`) | `NETWORK-VALIDATED` |
| Host Browser Access | Port `80` / `10081` | Port `10081:80` mapped to host | `RUNTIME-VALIDATED` |
| Domain Resolution | `www.seed-server.com` | Resolved via `127.0.0.1` host entry | `DOCUMENTED` |
| Tasks 1-4 Execution | Stored XSS, Cookie Theft, Worm, Defense | Tested against official task requirements | `TASK-TESTED` |
| Specification Alignment | SEED 20.04 Web Series | Cross-checked against official SEED PDF manual | `OFFICIAL-CROSS-CHECKED` |

---

## 4. Learning Layer Enhancements & Shell Fallbacks

1. **Local Build Control**: Uses local `Dockerfile`s allowing students to inspect application source files and configuration settings.
2. **Linux Shell Fallbacks**:
   - `bash` unavailable -> Fall back to `docker exec -it elgg-10.9.0.5 sh`
   - `ip` unavailable -> Fall back to `hostname -i` or `cat /etc/hosts`
   - `ss` unavailable -> Fall back to `netstat -tlnp` or `cat /proc/net/tcp`
