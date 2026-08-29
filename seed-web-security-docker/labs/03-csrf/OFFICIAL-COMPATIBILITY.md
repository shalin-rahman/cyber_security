# Lab 03 — Official SEED Compatibility Matrix & Specification

**Implementation Type**: Official SEED source adapted for Docker

This document explicitly separates the **Official SEED Lab Environment Specification** from the **Extended Learning Layer** provided in this repository.

---

## 1. Official SEED Specification

- **Official SEED Lab Title**: Cross-Site Request Forgery (CSRF) Attack Lab (Elgg)
- **Official SEED Manual URL**: https://seedsecuritylabs.org/Labs_20.04/Web/Web_CSRF_Elgg/
- **Textbook Correlation**: Chapter 10 — Cross-Site Request Forgery (*Computer & Internet Security*, 2nd Ed., Prof. Wenliang Du)
- **Official Image Dependencies**: `handsonsecurity/seed-server:apache-php`, `handsonsecurity/seed-image-mysql-csrf`
- **Official Network Topology**: Three-container architecture on bridge network `10.9.0.0/24`:
  - `10.9.0.5` -> Legitimate Elgg target site (`www.seed-server.com`)
  - `10.9.0.105` -> Malicious attacker website (`www.attacker32.com`)
  - `10.9.0.6` -> MySQL database (`elgg_csrf`)

---

## 2. Host Browser vs. Docker Container Network Architecture

```
HOST BROWSER (Windows / Linux / macOS)
    |
    |-- Target Site:   http://localhost:10082  OR  http://www.seed-server.com:10082
    |-- Attacker Site: http://localhost:10083  OR  http://www.attacker32.com:10083
    v
HOST NETWORK STACK (127.0.0.1 / localhost)
    |
    | Port Forwarding: Host 10082 -> Target:80  |  Host 10083 -> Attacker:80
    v
DOCKER ENGINE / WSL2 VM BRIDGE
    |
    | Virtual Bridge Interface: net-10.9.0.0-csrf (Subnet 10.9.0.0/24)
    v
CONTAINER USER SPACE
    |-- 10.9.0.5 (elgg-10.9.0.5-csrf container IP — internal container routing)
    |-- 10.9.0.105 (attacker-10.9.0.105 container IP — internal attacker site)
    |-- 10.9.0.6 (mysql-10.9.0.6-csrf container IP — internal database)
```

> **IMPORTANT HOST ROUTING NOTICE**:  
> Do **not** map `10.9.0.5` or `10.9.0.105` directly in your host `/etc/hosts` file when running Docker Desktop on Windows or macOS. Docker Desktop runs inside a lightweight WSL2 / Hyper-V VM where internal container IPs (`10.9.0.5`) are not routable from the host OS network adapter.  
>  
> To access the lab via domain names on host browsers, map:
> - `127.0.0.1 www.seed-server.com`
> - `127.0.0.1 www.attacker32.com`  
> Then visit `http://www.seed-server.com:10082` and `http://www.attacker32.com:10083` in your browser.

---

## 3. Environment Compatibility & Validation Matrix

| Feature | Official SEED Environment | Local Docker Learning Environment | Precise Validation Status |
|---------|---------------------------|-----------------------------------|---------------------------|
| Target Site | Elgg Social Network Platform | Built locally via `image_www/Dockerfile` | `BUILD-VALIDATED` |
| Attacker Site | Static Apache Server | Built locally via `image_attacker/Dockerfile` | `BUILD-VALIDATED` |
| Database Engine | MySQL 8.0 (`elgg_csrf` schema) | Built locally via `image_mysql/Dockerfile` | `BUILD-VALIDATED` |
| Container Lifecycle | `docker compose up -d` | Verified via `docker compose ps` | `RUNTIME-VALIDATED` |
| Bridge Network Isolation | `10.9.0.0/24` subnet | Assigned in `docker-compose.yml` (`net-10.9.0.0-csrf`) | `NETWORK-VALIDATED` |
| Host Ports | Ports `10082` and `10083` | Ports `10082:80` and `10083:80` mapped to host | `RUNTIME-VALIDATED` |
| Domain Resolution | `www.seed-server.com` & `www.attacker32.com` | Resolved via `127.0.0.1` host entries | `DOCUMENTED` |
| Tasks 1-4 Execution | GET/POST CSRF, Token Defense | Tested against official task requirements | `TASK-TESTED` |
| Specification Alignment | SEED 20.04 Web Series | Cross-checked against official SEED PDF manual | `OFFICIAL-CROSS-CHECKED` |

---

## 4. Learning Layer Enhancements & Shell Fallbacks

1. **Dual Domain Cross-Origin Simulation**: Direct support for testing session cookie auto-attach behavior across two distinct origins.
2. **Linux Shell Fallbacks**:
   - `bash` unavailable -> Fall back to `docker exec -it elgg-10.9.0.5-csrf sh`
   - `ip` unavailable -> Fall back to `hostname -i` or `cat /etc/hosts`
   - `ss` unavailable -> Fall back to `netstat -tlnp` or `cat /proc/net/tcp`
