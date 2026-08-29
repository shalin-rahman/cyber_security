# Documentation Module 02 — Docker Foundations for Cybersecurity Labs

This module covers core Docker concepts required for managing SEED web security lab containers.

---

## 1. Docker Architecture Overview

Docker separates application execution from host system dependencies by running workloads inside isolated containers.

```
+-------------------------------------------------------------------+
|                           Host Machine                            |
|                                                                   |
|   +-----------------------------------------------------------+   |
|   |                       Docker Engine                       |   |
|   |                                                           |   |
|   |   +-------------------+           +-------------------+   |   |
|   |   |   Container A     |           |   Container B     |   |   |
|   |   |  (Apache / PHP)   |           |    (MySQL DB)     |   |   |
|   |   +---------+---------+           +---------+---------+   |   |
|   |             |                               |             |   |
|   |             +------- Docker Network --------+             |   |
|   |                     (net-10.9.0.0)                        |   |
|   +-----------------------------------------------------------+   |
+-------------------------------------------------------------------+
```

---

## 2. Core Docker Concepts

### Images vs Containers

- **Docker Image**: A read-only template containing the application code, runtime libraries, environment variables, and configuration files. Images are immutable.
- **Docker Container**: A runnable instance of a Docker image. Containers add a thin writable layer on top of the underlying image layer.

### Docker Engine
The background service (`dockerd`) managing containers, images, networks, and volumes on the host system.

### Networks
Virtual networks managed by Docker allowing container-to-container communication. SEED labs use custom bridge networks (`10.9.0.0/24`) with assigned static IP addresses.

### Ports
Mapping host network ports to container network ports:
```yaml
ports:
  - "10080:80"  # Host port 10080 forwards to container port 80
```

### Volumes
Persistent storage mounted into a container, preserving database state across container container restarts.

### Docker Compose
A tool for defining and running multi-container Docker applications via declarative `docker-compose.yml` configuration files.

---

## 3. Command Reference

### Managing Containers
```bash
# Start containers in background
docker compose up -d

# Check running container status
docker compose ps

# View container output logs
docker compose logs -f <service_name>

# Stop containers
docker compose down

# Stop containers and delete named volumes (data reset)
docker compose down -v
```

### Interactive Execution inside Container
```bash
# Open interactive bash shell inside container
docker exec -it <container_name_or_id> bash

# Example: enter MySQL container
docker exec -it mysql-10.9.0.6 mysql -u root -pdees
```

### Network Inspection
```bash
# List all Docker networks
docker network ls

# Inspect specific SEED lab network
docker network inspect net-10.9.0.0-sqli
```
