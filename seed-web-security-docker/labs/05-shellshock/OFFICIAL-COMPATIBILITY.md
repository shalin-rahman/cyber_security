# Lab 05 — Official SEED Compatibility Matrix & Specification

This document explicitly separates the **Official SEED Lab Environment Specification** from the **Extended Learning Layer** provided in this repository.

---

## 1. Official SEED Specification

- **Official SEED Lab Title**: Shellshock Attack Lab
- **Official SEED Manual URL**: https://seedsecuritylabs.org/Labs_20.04/Web/Shellshock/
- **Textbook Correlation**: Chapter 3 — Shellshock Attack (*Computer & Internet Security*, Prof. Wenliang Du)
- **CVE References**: CVE-2014-6271, CVE-2014-7169
- **Official Image Dependencies**: `handsonsecurity/seed-server:apache-php`
- **Official Network Topology**: Single container CGI server on bridge network `10.9.0.0/24`:
  - `10.9.0.80` -> Apache CGI server providing `/cgi-bin/vul.cgi` (uses vulnerable Bash 4.3 copy `/bin/bash_shellshock`) and `/cgi-bin/safe.cgi` (uses patched `/bin/bash`)

---

## 2. Environment Compatibility Verification

| Feature | Official SEED Environment | Local Docker Learning Environment | Status |
|---------|---------------------------|-----------------------------------|--------|
| Web Engine | Apache 2.4 with mod_cgi | Built locally via `image_www/Dockerfile` | Verified |
| Vulnerable Binary | Bash 4.3 copy (`/bin/bash_shellshock`) | Included inside image via `Dockerfile` | Verified |
| Safe Binary | Patched `/bin/bash` | Included inside image via `Dockerfile` | Verified |
| Host Port | Port `10086` | Port `10086:80` mapped to host | Verified |
| Tasks 1-5 | Full task execution supported | Full task execution supported | Verified |

---

## 3. Learning Layer Enhancements

1. **Host Terminal Compatibility**:
   Exploit examples provided for both Linux bash (`curl`) and Windows PowerShell (`curl.exe`).

2. **3-Layer Operational Guidance**:
   - Layer 1: Container launch (`docker compose up -d --build`)
   - Layer 2: Interactive Linux shell (`docker exec -it shellshock-10.9.0.80 bash`) for testing binary function parsing (`env x='() { :; }; echo VULN' /bin/bash_shellshock -c "echo test"`)
   - Layer 3: Remote Code Execution, `/etc/passwd` exfiltration, and reverse shell listener triggers.
