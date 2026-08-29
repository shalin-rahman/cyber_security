# SEED Web Security Labs with Docker

A GitHub-ready learning repository for studying the SEED Labs web-security environments using Docker and Docker Compose.

## Scope

This repository focuses on the SEED Labs 2.0 Web Security category:

1. SQL Injection Attack Lab
2. Cross-Site Scripting (XSS) Attack Lab
3. Cross-Site Request Forgery (CSRF) Attack Lab
4. Clickjacking Attack Lab
5. Shellshock Vulnerability Lab

## Important answer: Can Docker alone run every SEED Lab?

**No. Docker alone should not be assumed to support every SEED lab in every category.**

SEED Labs 2.0 uses containers heavily, and many labs provide `Labsetup.zip`, `docker-compose.yml`, and Dockerfiles. The official web-security labs in this repository provide Docker-oriented setup packages.

However, the complete SEED Labs ecosystem includes operating-system, networking, cryptography, software-security, and other labs. Some experiments may depend on:

- host kernel behavior,
- low-level networking,
- privileged operations,
- packet capture or raw sockets,
- architecture-specific binaries,
- GUI/browser behavior,
- intentionally old operating-system behavior,
- VM configuration.

For those labs, Docker may be sufficient, Docker may need additional host capabilities, or a SEED-compatible Ubuntu VM may be the safer documented environment.

## Recommended environment

For the Web Security labs:

```text
Host Computer
    |
    +-- Linux host or Ubuntu VM
            |
            +-- Docker Engine
            +-- Docker Compose plugin
            +-- Browser
            +-- curl
            +-- SEED Lab containers
```

The most portable approach is:

```text
Windows/macOS/Linux
        |
        +-- Ubuntu VM or Linux host
                |
                +-- Docker
                        |
                        +-- SEED Web Lab Containers
```

## Repository structure

```text
seed-docker-web-security/
|
+-- README.md
+-- docs/
|   +-- 01-docker-from-zero.md
|   +-- 02-seed-labs-and-docker.md
|   +-- 03-common-lab-workflow.md
|   +-- 04-troubleshooting.md
|   +-- 05-docker-cheatsheet.md
|   +-- 06-learning-roadmap.md
|
+-- labs/
|   +-- 01-sql-injection.md
|   +-- 02-xss.md
|   +-- 03-csrf.md
|   +-- 04-clickjacking.md
|   +-- 05-shellshock.md
|
+-- .github/
    +-- CONTRIBUTING.md
```

## Learning rule

For every lab, do not simply run commands. Follow this order:

```text
1. Understand the security concept
2. Understand the lab topology
3. Inspect docker-compose.yml
4. Inspect Dockerfiles
5. Build the environment
6. Start containers
7. Verify containers and networking
8. Perform the official learning tasks
9. Observe logs and application behavior
10. Study the countermeasure
11. Destroy/reset the environment
12. Write your findings
```

## Official SEED Sources

The following official sources are included in the repository and are referenced by `docs/07-official-sources.md`:

1. SEED Labs Setup Guide  
   https://seedsecuritylabs.org/labsetup.html

2. SEED Labs 2.0 Overview  
   https://seedsecuritylabs.org/labs.html

3. SEED SQL Injection Lab  
   https://seedsecuritylabs.org/Labs_20.04/Web/Web_SQL_Injection/

4. SEED XSS Lab  
   https://seedsecuritylabs.org/Labs_20.04/Web/Web_XSS_Elgg/

5. SEED CSRF Lab  
   https://seedsecuritylabs.org/Labs_20.04/Web/Web_CSRF_Elgg/

For a detailed explanation of how these sources relate to the repository documentation, see:

```text
docs/07-official-sources.md
```

## Safety and authorization

Use these environments only for education and authorized experimentation. Run security experiments only against intentionally vulnerable lab targets or systems you own or are explicitly authorized to test.
