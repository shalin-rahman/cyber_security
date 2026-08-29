# Docker Module 01 — Docker Architecture and Foundations

This document introduces Docker Engine architecture, containerization concepts, and the Docker CLI workflow.

---

## 1. Docker Architecture

Docker uses a client-server architecture. The Docker CLI communicates with the Docker daemon (`dockerd`), which handles building, running, and managing containers.

```
+---------------------------------------------------------------+
|                         Host System                           |
|                                                               |
|  Docker Client (CLI)               Docker Daemon (dockerd)    |
|  $ docker run / exec   ========>  - Image Cache               |
|                                   - Container Management      |
|                                   - Network Drivers           |
|                                   - Volume Management         |
+---------------------------------------------------------------+
```

---

## 2. Core Concepts

### Containerization vs Virtualization
- **Virtualization**: Emulates physical hardware; requires a full guest operating system per VM.
- **Containerization**: Shares host OS kernel; isolates process space and filesystem using Linux namespaces and control groups (`cgroups`).

### Key Docker Components
- **Docker Client**: CLI utility (`docker`) used to issue management commands.
- **Docker Daemon**: Background daemon (`dockerd`) managing Docker objects.
- **Docker Images**: Read-only image layers containing software blueprints.
- **Docker Containers**: Runnable process instances of Docker images.
- **Docker Registry**: Remote repository storing Docker images (e.g., Docker Hub).
