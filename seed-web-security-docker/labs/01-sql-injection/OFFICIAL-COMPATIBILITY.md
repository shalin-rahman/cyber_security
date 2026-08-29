# Lab 01 — Official SEED Compatibility Matrix & Specification

This document explicitly separates the **Official SEED Lab Environment Specification** from the **Extended Learning Layer** provided in this repository.

---

## 1. Official SEED Specification

- **Official SEED Lab Title**: Web SQL Injection Attack Lab
- **Official SEED Manual URL**: https://seedsecuritylabs.org/Labs_20.04/Web/Web_SQL_Injection/
- **Textbook Correlation**: Chapter 12 — SQL Injection Attack (*Computer & Internet Security*, Prof. Wenliang Du)
- **Official Image Dependencies**: `handsonsecurity/seed-server:apache-php`, `handsonsecurity/seed-image-mysql-sqli`
- **Official Network Topology**: Two-container architecture on bridge network `10.9.0.0/24`:
  - `10.9.0.5` -> Apache 2.4 + PHP vulnerable web server
  - `10.9.0.6` -> MySQL 8.0 database with pre-populated `sqllab_users` schema

---

## 2. Environment Compatibility Verification

| Feature | Official SEED Environment | Local Docker Learning Environment | Status |
|---------|---------------------------|-----------------------------------|--------|
| Web Server Base | Apache 2.4 + PHP 7/8 | Built locally via `image_www/Dockerfile` | Verified |
| Database Base | MySQL 8.0 | Built locally via `image_mysql/Dockerfile` | Verified |
| Static IP Assignment | `10.9.0.5` / `10.9.0.6` | Assigned in `docker-compose.yml` (`net-10.9.0.0-sqli`) | Verified |
| Host Browser Access | Port `80` (or `10080` host map) | Port `10080:80` mapped to host | Verified |
| Domain Resolution | `www.seed-server.com` | Resolved via host `/etc/hosts` or `C:\Windows\...` | Verified |
| Official Task 1-4 Compatibility | Full task execution supported | Full task execution supported | Verified |

---

## 3. Learning Layer Enhancements

While preserving exact SEED lab task compatibility, this repository provides:

1. **Local Docker Build Controls**:
   Uses `docker compose up -d --build` so students can inspect `Dockerfile` logic, edit source files locally, and re-test without remote registry pulls.

2. **3-Layer Operational Guidance**:
   Structured step-by-step instructions for:
   - Layer 1: Host Docker management (`docker compose ps`, `docker logs`)
   - Layer 2: Interactive Linux shell (`docker exec -it www-10.9.0.5 bash`) for process and file permissions inspection
   - Layer 3: Web security payload execution, log streaming, and prepared statement defense implementation.
