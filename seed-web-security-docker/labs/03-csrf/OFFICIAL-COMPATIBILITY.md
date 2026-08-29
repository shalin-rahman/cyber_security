# Lab 03 — Official SEED Compatibility Matrix & Specification

This document explicitly separates the **Official SEED Lab Environment Specification** from the **Extended Learning Layer** provided in this repository.

---

## 1. Official SEED Specification

- **Official SEED Lab Title**: Cross-Site Request Forgery (CSRF) Attack Lab (Elgg)
- **Official SEED Manual URL**: https://seedsecuritylabs.org/Labs_20.04/Web/Web_CSRF_Elgg/
- **Textbook Correlation**: Chapter 10 — Cross-Site Request Forgery (*Computer & Internet Security*, Prof. Wenliang Du)
- **Official Image Dependencies**: `handsonsecurity/seed-server:apache-php`, `handsonsecurity/seed-image-mysql-csrf`
- **Official Network Topology**: Three-container architecture on bridge network `10.9.0.0/24`:
  - `10.9.0.5` -> Legitimate Elgg target site (`www.seed-server.com`)
  - `10.9.0.105` -> Malicious attacker website (`www.attacker32.com`)
  - `10.9.0.6` -> MySQL database (`elgg_csrf`)

---

## 2. Environment Compatibility Verification

| Feature | Official SEED Environment | Local Docker Learning Environment | Status |
|---------|---------------------------|-----------------------------------|--------|
| Target Site | Elgg Social Network Platform | Built locally via `image_www/Dockerfile` | Verified |
| Attacker Site | Static Apache Server | Built locally via `image_attacker/Dockerfile` | Verified |
| Database Engine | MySQL 8.0 (`elgg_csrf` schema) | Built locally via `image_mysql/Dockerfile` | Verified |
| Static IP Assignment | `10.9.0.5` / `10.9.0.105` / `10.9.0.6` | Assigned in `docker-compose.yml` (`net-10.9.0.0-csrf`) | Verified |
| Host Ports | Port `10082` (Target), `10083` (Attacker) | Ports `10082:80` and `10083:80` mapped to host | Verified |
| Cross-Origin Setup | `www.seed-server.com` & `www.attacker32.com` | Resolved via host `/etc/hosts` or `C:\Windows\...` | Verified |
| Official Tasks 1-4 | Full task execution supported | Full task execution supported | Verified |

---

## 3. Learning Layer Enhancements

1. **Dual Domain Cross-Origin Simulation**:
   Direct support for testing browser session cookie auto-attach behavior across two distinct origins.

2. **3-Layer Operational Guidance**:
   - Layer 1: Docker Compose multi-service management (`docker compose up -d --build`)
   - Layer 2: Interactive Linux shell access for both target (`elgg-10.9.0.5-csrf`) and attacker (`attacker-10.9.0.105`) containers
   - Layer 3: GET/POST CSRF exploitation, browser DevTools inspection, and anti-CSRF token defense validation.
