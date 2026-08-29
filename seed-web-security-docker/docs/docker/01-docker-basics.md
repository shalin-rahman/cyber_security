# Docker Basics — Architecture and Core Concepts

Docker is a platform for packaging and running applications inside isolated containers. This document explains what Docker is and how it works, with commands you can run immediately.

Official docs: https://docs.docker.com/

---

## 1. What Docker Does

Without Docker, running a lab requires installing Apache, PHP, MySQL, and configuring them all on your host machine. If something breaks, it affects your whole system.

With Docker, each application runs in an isolated container. The container has its own filesystem, network, and process space. When you are done, you delete the container and nothing is left on your host.

```
WITHOUT DOCKER                       WITH DOCKER
Host Machine                         Host Machine
+-----------------------------+       +-----------------------------+
| Your OS                     |       | Your OS                     |
| Apache (installed globally) |       |                             |
| PHP    (installed globally) |       | Docker Engine               |
| MySQL  (installed globally) |       | +-------------------------+ |
| Lab app files               |       | | Container: www          | |
|                             |       | | Apache + PHP + app      | |
|                             |       | +-------------------------+ |
|                             |       | +-------------------------+ |
|                             |       | | Container: mysql        | |
|                             |       | | MySQL database          | |
|                             |       | +-------------------------+ |
+-----------------------------+       +-----------------------------+
```

---

## 2. Key Docker Concepts

**Image** — A read-only snapshot of a filesystem. Like a blueprint. Built from a `Dockerfile`.

**Container** — A running instance of an image. Isolated, but lightweight. Multiple containers can run from the same image.

**Dockerfile** — A text file with step-by-step instructions for building an image.

**Docker Compose** — A tool for defining and running multi-container applications using a `docker-compose.yml` file.

**Registry** — A remote storage server for images. Docker Hub (`hub.docker.com`) is the default public registry.

---

## 3. Verify Docker is Installed and Running

```bash
# Check Docker client and server version
docker version

# Check Docker daemon status and system info (RAM, CPUs, storage driver)
docker info

# Run a test container to confirm Docker works end-to-end
docker run hello-world

# Check Docker Compose version
docker compose version
```

---

## 4. Images

```bash
# List all locally available images
docker images

# Pull an image from Docker Hub (does not run it)
docker pull ubuntu:22.04

# Build an image from a Dockerfile in the current directory
docker build -t my-image-name .

# Build with no cache (force fresh rebuild)
docker build --no-cache -t my-image-name .

# Remove a specific image
docker rmi my-image-name

# Remove all dangling (untagged) images
docker image prune

# Show image layer history
docker history my-image-name
```

---

## 5. Containers

```bash
# Run a container in foreground (blocks terminal)
docker run ubuntu:22.04 echo "Hello from container"

# Run a container in background (detached mode)
docker run -d ubuntu:22.04

# Run a container with an interactive shell
docker run -it ubuntu:22.04 bash

# List running containers
docker ps

# List all containers including stopped
docker ps -a

# Start a stopped container
docker start <container-name-or-id>

# Stop a running container gracefully
docker stop <container-name-or-id>

# Force kill a container immediately
docker kill <container-name-or-id>

# Remove a stopped container
docker rm <container-name-or-id>

# Remove a running container forcefully
docker rm -f <container-name-or-id>
```

---

## 6. Interacting with Running Containers

```bash
# Open an interactive shell inside a running container
docker exec -it <container-name> bash

# Run a single command inside a container without entering a shell
docker exec <container-name> cat /etc/hostname

# Copy a file FROM the container to your host
docker cp <container-name>:/var/www/html/index.php ./index.php

# Copy a file TO the container from your host
docker cp ./index.php <container-name>:/var/www/html/index.php

# View container stdout/stderr logs
docker logs <container-name>

# Stream logs in real time
docker logs -f <container-name>

# View last N lines of logs
docker logs --tail 50 <container-name>
```

---

## 7. Container Inspection

```bash
# Show all configuration details of a container (JSON format)
docker inspect <container-name>

# Extract just the container's IP address
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container-name>

# Show real-time resource usage (CPU, RAM, network I/O)
docker stats

# Show resource usage snapshot (no streaming)
docker stats --no-stream

# Show disk space used by Docker
docker system df
```

---

## 8. Cleanup

```bash
# Remove all stopped containers, unused networks, dangling images, build cache
docker system prune

# Same but also removes unused images (not just dangling ones)
docker system prune -a

# Remove everything including volumes (WARNING: destroys database data)
docker system prune -a --volumes
```

---

## 9. How Dockerfiles Work

A Dockerfile is read top to bottom. Each instruction creates a new image layer.

```dockerfile
# Start from an existing base image
FROM ubuntu:22.04

# Run a command during the build (installs software)
RUN apt-get update && apt-get install -y apache2 php

# Set an environment variable inside the image
ENV MYSQL_HOST=10.9.0.6

# Copy files from host into the image
COPY src /var/www/html

# Document which port the application uses
EXPOSE 80

# Command to run when the container starts
CMD ["apache2ctl", "-DFOREGROUND"]
```

Build it:
```bash
docker build -t my-apache-app .
docker run -d -p 8080:80 my-apache-app
# Now access: http://localhost:8080
```
