# Docker Module 02 — Images and Container Layer Mechanics

This module explains how Docker images are built from layered filesystems, how container writable layers work, and how to inspect image histories and container states.

---

## 1. Images vs. Container Writable Layers

A Docker image is a read-only template built from a series of stacked filesystem layers specified in a `Dockerfile`. Every instruction (`FROM`, `RUN`, `COPY`, `ENV`) adds a new read-only layer to the image.

When Docker starts a container, it places a thin, isolated **writable container layer** (the "container layer") on top of the read-only image layers using a Copy-on-Write (CoW) filesystem driver (such as `overlay2`).

```
+-----------------------------------------------------------------------+
| WRITABLE CONTAINER LAYER (temporary container state & runtime changes)|
+-----------------------------------------------------------------------+
| READ-ONLY LAYER 4: COPY src /var/www/html (Application source code)  |
+-----------------------------------------------------------------------+
| READ-ONLY LAYER 3: ENV MYSQL_HOST=10.9.0.6 (Environment configuration)|
+-----------------------------------------------------------------------+
| READ-ONLY LAYER 2: RUN apt-get install -y apache2 php mysql-client    |
+-----------------------------------------------------------------------+
| READ-ONLY LAYER 1: FROM ubuntu:20.04 (Base Operating System user space)|
+-----------------------------------------------------------------------+
```

### Key Differences

- **Image**: Immutable (read-only), shared across containers, persistent on disk.
- **Container Layer**: Mutable (read-write), unique to a single container instance, destroyed when `docker rm` is executed unless backed up by a persistent volume.

---

## 2. Image Inspection Commands

Run these on your host terminal:

```bash
# List all locally available Docker images
docker image ls

# Show detailed layer history of a specific lab image
docker history seed-image-www-sqli

# Inspect detailed image metadata (JSON format)
docker image inspect seed-image-www-sqli

# Build an image from a local Dockerfile
cd labs/01-sql-injection/image_www
docker build -t seed-image-www-sqli .

# Build with no layer caching (force clean build)
docker build --no-cache -t seed-image-www-sqli .

# Remove an image from local storage
docker image rm seed-image-www-sqli
```

---

## 3. Container Lifecycle Management

```bash
# Create and start a container from an image in background mode
docker run -d --name www-test -p 10080:80 seed-image-www-sqli

# List running containers
docker ps

# List all containers (including stopped or crashed containers)
docker ps -a

# View container exit codes and status
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.ExitCode}}"

# Stop a running container gracefully (sends SIGTERM, then SIGKILL after 10s)
docker stop www-test

# Start an existing stopped container
docker start www-test

# Force-kill a running container immediately (sends SIGKILL)
docker kill www-test

# Remove a stopped container
docker rm www-test

# Force-remove a running container
docker rm -f www-test
```

---

## 4. Container Copy and Diff Inspection

You can inspect changes made to the container's writable layer or copy files between host and container without entering shell:

```bash
# Show file changes made in the container's writable layer (A = Added, C = Changed, D = Deleted)
docker diff www-10.9.0.5

# Copy a file from the host machine INTO a running container
docker cp ./index.php www-10.9.0.5:/var/www/html/index.php

# Copy a file FROM a running container to the host machine
docker cp www-10.9.0.5:/var/log/apache2/access.log ./access.log
```

---

## 5. Committing Container Writable Layers

If you make modifications inside a container shell and want to save the new state as a reusable image:

```bash
# Create a new image snapshot from a running container
docker commit www-10.9.0.5 my-custom-sqli-backup:v1

# Verify the new image exists locally
docker image ls | grep my-custom-sqli-backup
```
