# Linux Module 04 — Process Management and Service Inspection

This document explains process management, PID isolation, and inspecting service daemons (Apache, MySQL) inside container environments.

---

## 1. Process Isolation in Docker

Docker containers use Linux PID (Process ID) namespaces. Inside a container, the primary application process runs as PID 1.

```
Host Process Space (Ubuntu / WSL2)
  |
  +-- PID 4512 : dockerd
  +-- PID 8910 : containerd-shim -> [Spawns Container]
                                         |
                                         v
                      Container Process Space (net-10.9.0.0)
                        |
                        +-- PID 1  : apache2 -DFOREGROUND
                        +-- PID 14 : apache2 (worker www-data)
                        +-- PID 15 : apache2 (worker www-data)
```

---

## 2. Command Reference

### Command 1: `ps`

- **What it does**: Reports a snapshot of the current active processes.
- **Why it matters**: Displays running background services and active shells inside the container.
- **SEED Lab Application**: Run `ps` inside `www-10.9.0.5` to verify Apache process status.

### Command 2: `ps aux`

- **What it does**: Displays a full list of all processes running across all users, including CPU/Memory utilization, PID, terminal, and exact command arguments.
- **Why it matters**: Reveals background worker processes, service owners (`root` vs `www-data` vs `mysql`), and startup options.
- **SEED Lab Application**: Run `ps aux` in `elgg-10.9.0.5` to identify master Apache process (PID 1, root) and worker processes (`www-data`).

### Command 3: `pgrep`

- **What it does**: Looks up processes based on name and prints matching Process IDs (PIDs).
- **Why it matters**: Quickly checks if a specific daemon is active without parsing full process text.
- **SEED Lab Application**: Run `pgrep mysqld` in the MySQL container to confirm database process activity.

### Command 4: `top` (if installed)

- **What it does**: Displays real-time dynamic processor and memory utilization for active processes.
- **Why it matters**: Identifies resource-intensive database queries or runaway container scripts.
- **SEED Lab Application**: Monitor system CPU during automated script execution or database seeding.
