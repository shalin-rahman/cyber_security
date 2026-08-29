# Lab 04 — Official SEED Compatibility Matrix & Specification

This document explicitly separates the **Official SEED Lab Environment Specification** from the **Extended Learning Layer** provided in this repository.

---

## 1. Official SEED Specification

- **Official SEED Lab Title**: Clickjacking Attack Lab
- **Official SEED Manual URL**: https://seedsecuritylabs.org/Labs_20.04/Web/Web_Clickjacking/
- **Textbook Correlation**: Chapter 13 — Clickjacking Attack (*Computer & Internet Security*, Prof. Wenliang Du)
- **Official Image Dependencies**: `handsonsecurity/seed-server:apache-php`
- **Official Network Topology**: Two-container architecture on bridge network `10.9.0.0/24`:
  - `10.9.0.80` -> Legitimate target site (`www.cjlab.com`)
  - `10.9.0.81` -> Attacker UI redress page (`www.cjlab-attacker.com`)

---

## 2. Environment Compatibility Verification

| Feature | Official SEED Environment | Local Docker Learning Environment | Status |
|---------|---------------------------|-----------------------------------|--------|
| Target Site | Web portal with dangerous action button | Built locally via `image_target/Dockerfile` | Verified |
| Attacker Site | Transparent iframe overlay page | Built locally via `image_attacker/Dockerfile` | Verified |
| Static IP Assignment | `10.9.0.80` / `10.9.0.81` | Assigned in `docker-compose.yml` (`net-10.9.0.0-clickjacking`) | Verified |
| Host Ports | Port `10084` (Target), `10085` (Attacker) | Ports `10084:80` and `10085:80` mapped to host | Verified |
| Domain Resolution | `www.cjlab.com` & `www.cjlab-attacker.com` | Resolved via host `/etc/hosts` or `C:\Windows\...` | Verified |
| Official Tasks 1-3 | Full task execution supported | Full task execution supported | Verified |

---

## 3. Learning Layer Enhancements

1. **Browser Inspector Transparency Testing**:
   Guided steps for adjusting iframe `opacity` in DevTools to visualize alignment tricks.

2. **3-Layer Operational Guidance**:
   - Layer 1: Host container management (`docker compose up -d --build`)
   - Layer 2: Interactive Linux shell access for inspecting Apache configuration (`/etc/apache2/sites-enabled/000-default.conf`)
   - Layer 3: UI redress attack execution, `X-Frame-Options: DENY` implementation, and CSP `frame-ancestors` defense.
