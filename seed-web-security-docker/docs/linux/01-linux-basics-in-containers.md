# Linux Module 01 — Linux Basics inside Docker Containers

This document teaches fundamental Linux commands specifically within the context of Docker containers in the SEED Web Security Labs.

---

## 1. Entering a Container Environment

To execute Linux commands inside a container, spawn an interactive shell using `docker exec`:

```bash
docker exec -it <container_name> bash
```

```
[ Host System Terminal ]
           |
           | docker exec -it www-10.9.0.5 bash
           v
+-------------------------------------------------------+
| Container User-Space Execution Environment            |
|                                                       |
| root@www-10.9.0.5:/var/www/html#                     |
|  - Isolated filesystem (/var/www/html)                |
|  - Container-specific process table                   |
|  - Container-specific network interfaces              |
+-------------------------------------------------------+
```

---

## 2. Command Reference: What, Why, and Lab Application

### Command 1: `pwd`

- **What it does**: Prints the absolute path of the current working directory.
- **Why it matters**: Confirms where you are in the filesystem hierarchy before modifying files or executing commands.
- **SEED Lab Application**: After executing `docker exec -it www-10.9.0.5 bash`, run `pwd` to verify if Apache's web root (`/var/www/html`) is your active directory.

### Command 2: `whoami`

- **What it does**: Displays the current active user name.
- **Why it matters**: Verifies user privilege level (e.g., `root` vs unprivileged `www-data`).
- **SEED Lab Application**: Run `whoami` inside `elgg-10.9.0.5` to verify whether your container shell operates with root permissions.

### Command 3: `id`

- **What it does**: Displays numeric user ID (`uid`), group ID (`gid`), and group memberships.
- **Why it matters**: Demonstrates access control boundaries and privilege context.
- **SEED Lab Application**: Compare `id` output when logged in as root versus when inspecting the process user of Apache (`www-data`).

### Command 4: `ls -la`

- **What it does**: Lists all files and directories, including hidden files, permissions, owners, and file sizes.
- **Why it matters**: Reveals application structure, configuration files, and permissions.
- **SEED Lab Application**: Run inside `mysql-10.9.0.6` database container to view database storage directories and entrypoint scripts.

### Command 5: `uname -a`

- **What it does**: Prints system kernel architecture and operating system kernel version.
- **Why it matters**: Proves that the container shares the host Linux kernel (or WSL2 kernel) rather than running an independent operating system kernel.
- **SEED Lab Application**: Run `uname -a` on the host machine and inside the container to observe that the kernel version string is identical.
