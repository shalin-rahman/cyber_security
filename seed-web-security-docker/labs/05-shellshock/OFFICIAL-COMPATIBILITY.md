# Lab 05 — Official SEED Compatibility Matrix & Specification

**Implementation Type**: Official SEED source adapted for Docker

This document explicitly separates the **Official SEED Lab Environment Specification** from the **Extended Learning Layer** provided in this repository.

---

## 1. Official SEED Specification

- **Official SEED Lab Title**: Shellshock Attack Lab
- **Official SEED Manual URL**: https://seedsecuritylabs.org/Labs_20.04/Web/Shellshock/
- **Textbook Correlation**: Chapter 3 — Shellshock Attack (*Computer & Internet Security*, 2nd Ed., Prof. Wenliang Du)
- **CVE References**: CVE-2014-6271, CVE-2014-7169
- **Official Image Dependencies**: `handsonsecurity/seed-server:apache-php`
- **Official Network Topology**: Single container CGI server on bridge network `10.9.0.0/24`:
  - `10.9.0.80` -> Apache CGI server providing `/cgi-bin/vul.cgi` (uses vulnerable Bash 4.3 copy `/bin/bash_shellshock`) and `/cgi-bin/safe.cgi` (uses patched `/bin/bash`)

---

## 2. Host Browser vs. Docker Container Network Architecture

```
HOST CLIENT (curl.exe / Browser on Windows / Linux / macOS)
    |
    | Connects to: http://localhost:10086/cgi-bin/vul.cgi
    v
HOST NETWORK STACK (127.0.0.1 / localhost)
    |
    | Port Forwarding Rule: Host Port 10086 -> Container Port 80
    v
DOCKER ENGINE / WSL2 VM BRIDGE
    |
    | Virtual Bridge Interface: net-10.9.0.0-shellshock (Subnet 10.9.0.0/24)
    v
CONTAINER USER SPACE
    |-- 10.9.0.80 (shellshock-10.9.0.80 container IP — internal container routing)
```

> **IMPORTANT HOST ROUTING NOTICE**:  
> Internal container IP `10.9.0.80` is used inside the Docker bridge network. For host clients (PowerShell `curl.exe` or host browser), connect via `http://localhost:10086/cgi-bin/vul.cgi`.

---

## 3. Environment Compatibility & Validation Matrix

| Feature | Official SEED Environment | Local Docker Learning Environment | Precise Validation Status |
|---------|---------------------------|-----------------------------------|---------------------------|
| Web Engine | Apache 2.4 with mod_cgi | Built locally via `image_www/Dockerfile` | `BUILD-VALIDATED` |
| Vulnerable Binary | Bash 4.3 copy (`/bin/bash_shellshock`) | Included inside image via `Dockerfile` | `BUILD-VALIDATED` |
| Safe Binary | Patched `/bin/bash` | Included inside image via `Dockerfile` | `BUILD-VALIDATED` |
| Container Lifecycle | `docker compose up -d` | Verified via `docker compose ps` | `RUNTIME-VALIDATED` |
| Bridge Network Isolation | `10.9.0.0/24` subnet | Assigned in `docker-compose.yml` (`net-10.9.0.0-shellshock`) | `NETWORK-VALIDATED` |
| Host Port | Port `10086` | Port `10086:80` mapped to host | `RUNTIME-VALIDATED` |
| Tasks 1-5 Execution | RCE, File Read, Header Vectors, Reverse Shell | Tested against official task requirements | `TASK-TESTED` |
| Specification Alignment | SEED 20.04 Web Series | Cross-checked against official SEED PDF manual | `OFFICIAL-CROSS-CHECKED` |

---

## 4. Learning Layer Enhancements & Shell Fallbacks

1. **Host Terminal Parity**: Direct command support for Linux bash (`curl`) and Windows PowerShell (`curl.exe`).
2. **Linux Shell Fallbacks**:
   - `bash` unavailable -> Fall back to `docker exec -it shellshock-10.9.0.80 sh`
   - `ip` unavailable -> Fall back to `hostname -i` or `cat /etc/hosts`
   - `ss` unavailable -> Fall back to `netstat -tlnp` or `cat /proc/net/tcp`
