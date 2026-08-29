# Lab 02 — Official SEED Compatibility Matrix & Specification

This document explicitly separates the **Official SEED Lab Environment Specification** from the **Extended Learning Layer** provided in this repository.

---

## 1. Official SEED Specification

- **Official SEED Lab Title**: Cross-Site Scripting (XSS) Attack Lab (Elgg)
- **Official SEED Manual URL**: https://seedsecuritylabs.org/Labs_20.04/Web/Web_XSS_Elgg/
- **Textbook Correlation**: Chapter 11 — Cross-Site Scripting Attack (*Computer & Internet Security*, Prof. Wenliang Du)
- **Official Image Dependencies**: `handsonsecurity/seed-server:apache-php`, `handsonsecurity/seed-image-mysql-xss-elgg`
- **Official Network Topology**: Two-container architecture on bridge network `10.9.0.0/24`:
  - `10.9.0.5` -> Apache + PHP Elgg Social Network
  - `10.9.0.6` -> MySQL 8.0 containing `elgg` database and default profiles (`alice`, `samy`, `boby`)

---

## 2. Environment Compatibility Verification

| Feature | Official SEED Environment | Local Docker Learning Environment | Status |
|---------|---------------------------|-----------------------------------|--------|
| Application Framework | Elgg Social Network Platform | Built locally via `image_www/Dockerfile` | Verified |
| Database Engine | MySQL 8.0 (`elgg` schema) | Built locally via `image_mysql/Dockerfile` | Verified |
| Static IP Assignment | `10.9.0.5` / `10.9.0.6` | Assigned in `docker-compose.yml` (`net-10.9.0.0-xss`) | Verified |
| Host Browser Access | Port `80` (or `10081` host map) | Port `10081:80` mapped to host | Verified |
| Domain Resolution | `www.seed-server.com` | Resolved via host `/etc/hosts` or `C:\Windows\...` | Verified |
| Official Task 1-4 Compatibility | Full task execution supported | Full task execution supported | Verified |

---

## 3. Learning Layer Enhancements

1. **Self-Contained Local Build**:
   All container images build directly from local source files, ensuring full transparency of PHP and Apache settings.

2. **3-Layer Operational Guidance**:
   - Layer 1: Host container orchestration (`docker compose up -d --build`)
   - Layer 2: Interactive Linux shell inspection (`docker exec -it elgg-10.9.0.5 bash`) for Apache logs and database queries
   - Layer 3: Stored XSS injection, cookie stealing simulation, worm propagation, and `htmlspecialchars()` output encoding defense.
