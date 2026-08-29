# Docker Module 02 — Images and Containers

This document explains Docker images, container layer mechanics, and container lifecycle commands.

---

## 1. Images and Writable Layers

A Docker image consists of ordered, read-only filesystem layers. When Docker creates a container from an image, it adds a thin, writable container layer on top.

```
+---------------------------------------------------------------+
| Writable Container Layer (temporary state, container changes) |
+---------------------------------------------------------------+
| Read-Only Image Layer: Application Source (Elgg / PHP)        |
+---------------------------------------------------------------+
| Read-Only Image Layer: Web Server (Apache 2.4)                |
+---------------------------------------------------------------+
| Read-Only Image Layer: Base OS User-Space (Ubuntu / Debian)   |
+---------------------------------------------------------------+
```

---

## 2. Command Reference

### Image Management
```bash
# List local images
docker image ls

# Pull image from Docker Hub
docker pull handsonsecurity/seed-image-www-sqli

# Remove unused image
docker image rm <image_id>
```

### Container Lifecycle
```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Start / Stop existing container
docker start <container_name>
docker stop <container_name>

# Execute command inside running container
docker exec -it <container_name> bash
```
