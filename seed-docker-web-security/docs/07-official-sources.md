# Official SEED Labs Sources

This repository is designed to be used together with the official SEED Labs documentation. The following pages are the primary references for environment setup and the web-security labs documented here.

## 1. SEED Labs Setup Guide

https://seedsecuritylabs.org/labsetup.html

Use this as the starting point for:

- supported lab environments;
- Ubuntu and VM setup guidance;
- Docker-related environment preparation;
- platform considerations;
- SEED Lab installation requirements.

---

## 2. SEED Labs 2.0 Overview

https://seedsecuritylabs.org/labs.html

Use this page to:

- explore SEED Labs 2.0 categories;
- identify available security labs;
- understand the broader SEED Labs curriculum;
- locate official lab pages and materials.

---

## 3. SEED SQL Injection Lab

https://seedsecuritylabs.org/Labs_20.04/Web/Web_SQL_Injection/

Primary reference for:

- official SQL Injection lab setup;
- Labsetup package;
- Docker/container environment;
- lab topology;
- official learning tasks;
- countermeasures.

Related repository document:

- `labs/01-sql-injection.md`

---

## 4. SEED Cross-Site Scripting (XSS) Lab

https://seedsecuritylabs.org/Labs_20.04/Web/Web_XSS_Elgg/

Primary reference for:

- official XSS lab setup;
- containerized environment;
- hostname and web application configuration;
- official learning tasks;
- XSS security concepts and countermeasures.

Related repository document:

- `labs/02-xss.md`

---

## 5. SEED Cross-Site Request Forgery (CSRF) Lab

https://seedsecuritylabs.org/Labs_20.04/Web/Web_CSRF_Elgg/

Primary reference for:

- official CSRF lab setup;
- containerized web environment;
- authenticated browser/session behavior;
- official learning tasks;
- CSRF defenses.

Related repository document:

- `labs/03-csrf.md`

---

# Recommended Documentation Reading Order

```text
SEED Labs Setup Guide
        |
        v
Docker From Zero
        |
        v
SEED Labs 2.0 Overview
        |
        v
Common Docker Lab Workflow
        |
        v
SQL Injection
        |
        v
XSS
        |
        v
CSRF
        |
        v
Other SEED Web Security Labs
```

# Repository Documentation vs Official Documentation

This repository should be used as a structured learning guide.

```text
Official SEED Documentation
        +
This Repository's Docker Explanation
        +
Your Lab Notes
        =
Complete Learning Record
```

The official SEED documentation remains the source of truth for:

- the exact lab version;
- Labsetup archive;
- Docker configuration;
- host mappings;
- IP addresses;
- credentials provided for the lab;
- task requirements;
- environment-specific instructions.

Do not assume that configuration from one lab can be copied to another lab without checking the official lab documentation.
