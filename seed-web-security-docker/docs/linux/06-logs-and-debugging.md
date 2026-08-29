# Linux Module 06 — Log Inspection and Diagnostics

This document covers log inspection techniques, distinguishing between container stdout/stderr logs and application logs generated inside the container filesystem.

---

## 1. Dual-Layer Logging Architecture

In containerized environments, logging exists at two distinct levels:

```
Level 1: Container Level (Docker Engine)
  Collects standard output (stdout) and standard error (stderr) from PID 1.
  Access via: docker compose logs / docker logs <container>

Level 2: Internal Application Level (Container Filesystem)
  Log files created by Apache, PHP, or MySQL inside the container.
  Access via: cat /var/log/apache2/error.log / tail -f /var/log/apache2/access.log
```

---

## 2. Command Reference

### Command 1: `docker compose logs`

- **What it does**: Fetches aggregated logs from all services declared in `docker-compose.yml`.
- **Why it matters**: Provides a high-level view of application startup, database initialization, and fatal container crashes.
- **SEED Lab Application**: Run `docker compose logs` in `labs/01-sql-injection` to verify MySQL database startup.

### Command 2: `docker compose logs -f <service>`

- **What it does**: Streams container logs continuously in real time.
- **Why it matters**: Monitors incoming HTTP requests and application output as you perform web attacks in the browser.
- **SEED Lab Application**: Stream web container logs (`docker compose logs -f www`) while submitting SQL injection payloads.

### Command 3: `tail -f /var/log/apache2/access.log`

- **What it does**: Streams the tail end of Apache's HTTP access log file inside the container.
- **Why it matters**: Displays raw HTTP request lines, user agents, status codes, and request URIs.
- **SEED Lab Application**: Inspect User-Agent header injection in real time during Task 2 of the Shellshock lab.

### Command 4: `cat /var/log/apache2/error.log`

- **What it does**: Displays Apache error log entries.
- **Why it matters**: Diagnoses PHP syntax errors, database connection failures, and 500 Internal Server Errors.
- **SEED Lab Application**: Check error logs when Elgg fails to connect to MySQL during initial deployment.
