# Lab 04 — Official SEED Compatibility Matrix & Specification

**Implementation Type**: Official SEED source adapted for Docker

This document explicitly separates the **Official SEED Lab Environment Specification** from the **Extended Learning Layer** provided in this repository.

---

## 1. Official SEED Specification

- **Official SEED Lab Title**: Clickjacking Attack Lab
- **Official SEED Manual URL**: https://seedsecuritylabs.org/Labs_20.04/Web/Web_Clickjacking/
- **Textbook Correlation**: Chapter 13 — Clickjacking Attack (*Computer & Internet Security*, 2nd Ed., Prof. Wenliang Du)
- **Official Image Dependencies**: `handsonsecurity/seed-server:apache-php`
- **Official Network Topology**: Two-container architecture on bridge network `10.9.0.0/24`:
  - `10.9.0.80` -> Legitimate target site (`www.cjlab.com`)
  - `10.9.0.81` -> Attacker UI redress page (`www.cjlab-attacker.com`)

---

## 2. Host Browser vs. Docker Container Network Architecture

```
HOST BROWSER (Windows / Linux / macOS)
    |
    |-- Target Site:   http://localhost:10084  OR  http://www.cjlab.com:10084
    |-- Attacker Site: http://localhost:10085  OR  http://www.cjlab-attacker.com:10085
    v
HOST NETWORK STACK (127.0.0.1 / localhost)
    |
    | Port Forwarding: Host 10084 -> Target:80  |  Host 10085 -> Attacker:80
    v
DOCKER ENGINE / WSL2 VM BRIDGE
    |
    | Virtual Bridge Interface: net-10.9.0.0-clickjacking (Subnet 10.9.0.0/24)
    v
CONTAINER USER SPACE
    |-- 10.9.0.80 (cjlab-10.9.0.80 container IP — internal container routing)
    |-- 10.9.0.81 (cjlab-attacker-10.9.0.81 container IP — internal attacker site)
```

> **IMPORTANT HOST ROUTING NOTICE**:  
> Do **not** map `10.9.0.80` or `10.9.0.81` directly in your host `/etc/hosts` file when running Docker Desktop on Windows or macOS. Docker Desktop runs inside a lightweight WSL2 / Hyper-V VM where internal container IPs (`10.9.0.80`) are not routable from the host OS network adapter.  
>  
> To access the lab via domain names on host browsers, map:
> - `127.0.0.1 www.cjlab.com`
> - `127.0.0.1 www.cjlab-attacker.com`  
> Then visit `http://www.cjlab.com:10084` and `http://www.cjlab-attacker.com:10085` in your browser.

---

## 3. Environment Compatibility & Validation Matrix

| Feature | Official SEED Environment | Local Docker Learning Environment | Precise Validation Status |
|---------|---------------------------|-----------------------------------|---------------------------|
| Target Site | Web portal with action button | Built locally via `image_target/Dockerfile` | `BUILD-VALIDATED` |
| Attacker Site | Transparent iframe overlay | Built locally via `image_attacker/Dockerfile` | `BUILD-VALIDATED` |
| Container Lifecycle | `docker compose up -d` | Verified via `docker compose ps` | `RUNTIME-VALIDATED` |
| Bridge Network Isolation | `10.9.0.0/24` subnet | Assigned in `docker-compose.yml` (`net-10.9.0.0-clickjacking`) | `NETWORK-VALIDATED` |
| Host Ports | Ports `10084` and `10085` | Ports `10084:80` and `10085:80` mapped to host | `RUNTIME-VALIDATED` |
| Domain Resolution | `www.cjlab.com` & `www.cjlab-attacker.com` | Resolved via `127.0.0.1` host entries | `DOCUMENTED` |
| Tasks 1-3 Execution | UI Redress, DevTools, Headers Defense | Tested against official task requirements | `TASK-TESTED` |
| Specification Alignment | SEED 20.04 Web Series | Cross-checked against official SEED PDF manual | `OFFICIAL-CROSS-CHECKED` |

---

## 4. Learning Layer Enhancements & Shell Fallbacks

1. **Browser Inspector Transparency Testing**: Guided steps for adjusting iframe `opacity` in DevTools to visualize alignment tricks.
2. **Linux Shell Fallbacks**:
   - `bash` unavailable -> Fall back to `docker exec -it cjlab-10.9.0.80 sh`
   - `ip` unavailable -> Fall back to `hostname -i` or `cat /etc/hosts`
   - `ss` unavailable -> Fall back to `netstat -tlnp` or `cat /proc/net/tcp`
