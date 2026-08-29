# Linux Module 03 — Users, Groups, and File Permissions

This document covers Linux user privilege management and permission controls within container environments.

---

## 1. User and Privilege Architecture inside Containers

Web applications should adhere to the principle of least privilege. In production environments, web servers run under unprivileged dedicated user accounts (e.g., `www-data`), whereas container setup procedures are performed as `root`.

```
Container Process Space
  |
  +--- Container Setup / Management  --> Running as 'root' (UID 0)
  |
  +--- Apache HTTP Server Worker     --> Running as 'www-data' (UID 33)
  |
  +--- MySQL Database Daemon        --> Running as 'mysql' (UID 999)
```

---

## 2. Command Reference

### Command 1: `whoami`

- **What it does**: Displays the current user account name executing the shell.
- **Why it matters**: Verifies whether an interactive shell has root privileges or restricted application privileges.
- **SEED Lab Application**: Verify that entering the container via `docker exec -it <container> bash` grants root access, allowing configuration inspection.

### Command 2: `id`

- **What it does**: Shows numeric UID, GID, and effective group memberships for a user.
- **Why it matters**: Demonstrates system-level privilege boundaries.
- **SEED Lab Application**: Run `id www-data` inside `elgg-10.9.0.5` to verify the non-root credentials of the Apache web worker process.

### Command 3: `ls -l`

- **What it does**: Lists files with long format showing file permissions (rwx), link count, owner, group, size, and modification time.
- **Why it matters**: Determines whether application files are writable by the web server user.
- **SEED Lab Application**: Inspect permissions on `/var/www/html/elgg-config.php` to ensure sensitive database credentials are read-only.

### Command 4: `chown`

- **What it does**: Changes file or directory ownership (user and group).
- **Why it matters**: Restructures file ownership so web processes can read or write uploads without running as root.
- **SEED Lab Application**: Observe how file uploads directories (`/var/www/html/data`) are owned by `www-data:www-data`.

### Command 5: `chmod`

- **What it does**: Modifies file access permissions for owner, group, and others.
- **Why it matters**: Enforces read/write/execute restriction boundaries.
- **SEED Lab Application**: Check execution permissions (`+x`) on `/usr/lib/cgi-bin/vul.cgi` in the Shellshock lab.
