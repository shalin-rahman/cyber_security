# Docker Compose — Multi-Container Orchestration

Docker Compose lets you define and run multiple containers together using a single `docker-compose.yml` file. All labs in this repository use Compose.

Official docs: https://docs.docker.com/compose/

---

## 1. Why Compose

Without Compose, starting Lab 01 requires two separate commands with complex flags:

```bash
# Without Compose (tedious, error-prone):
docker run -d --name mysql-10.9.0.6 \
  --network lab-net --ip 10.9.0.6 \
  -e MYSQL_ROOT_PASSWORD=dees \
  seed-image-mysql-sqli

docker run -d --name www-10.9.0.5 \
  --network lab-net --ip 10.9.0.5 \
  -p 10080:80 \
  --depends-on mysql-10.9.0.6 \
  seed-image-www-sqli
```

With Compose, all of that is declared in `docker-compose.yml` and started with one command:

```bash
docker compose up -d --build
```

---

## 2. Reading a docker-compose.yml File

```yaml
# docker-compose.yml — Lab 01 SQL Injection

services:

  www:                                    # Service name (logical)
    build: ./image_www                    # Build from this Dockerfile directory
    image: seed-image-www-sqli           # Tag the resulting image with this name
    container_name: www-10.9.0.5         # Container name (used in docker exec)
    depends_on:
      - mysql                             # Start mysql before www
    networks:
      net-10.9.0.0:
        ipv4_address: 10.9.0.5           # Fixed IP on the Docker bridge
    ports:
      - "10080:80"                        # Host port 10080 -> Container port 80
    environment:
      - MYSQL_HOST=10.9.0.6              # Env var available inside the container

  mysql:
    build: ./image_mysql
    image: seed-image-mysql-sqli
    container_name: mysql-10.9.0.6
    networks:
      net-10.9.0.0:
        ipv4_address: 10.9.0.6           # Fixed IP — web container connects here
    environment:
      - MYSQL_ROOT_PASSWORD=dees

networks:
  net-10.9.0.0:
    name: net-10.9.0.0-sqli              # Named network (isolated per lab)
    ipam:
      config:
        - subnet: 10.9.0.0/24            # All containers in this /24 subnet
```

---

## 3. Essential Compose Commands

```bash
# Build images and start all services in detached (background) mode
docker compose up -d --build

# Start without rebuilding (uses cached images)
docker compose up -d

# Show running containers for this Compose project
docker compose ps

# View logs for all services
docker compose logs

# Stream logs in real time (Ctrl+C to stop)
docker compose logs -f

# Stream logs for one specific service
docker compose logs -f www

# Stop containers (keeps volumes — data is preserved)
docker compose down

# Stop containers AND remove volumes (database data wiped)
docker compose down -v

# Rebuild images without starting
docker compose build

# Rebuild with no cache (ignores previously built layers)
docker compose build --no-cache

# Rebuild a single service only
docker compose build www

# Restart a single service without touching others
docker compose restart www

# Pull latest base images (not needed for local builds)
docker compose pull
```

---

## 4. Running Commands Inside a Compose Service

```bash
# Open interactive shell in a specific service container
docker compose exec www bash
docker compose exec mysql bash

# Run a one-off command without entering shell
docker compose exec mysql mysql -u root -pdees -e "SHOW DATABASES;"

# The above is equivalent to:
docker exec -it mysql-10.9.0.6 mysql -u root -pdees -e "SHOW DATABASES;"
```

---

## 5. Compose Project Isolation

Each lab has its own named network (e.g., `net-10.9.0.0-sqli`, `net-10.9.0.0-xss`). Running two labs at the same time can conflict if they use the same host ports or container IPs. Stop one lab before starting another:

```bash
# Stop Lab 01
cd labs/01-sql-injection
docker compose down

# Start Lab 02
cd ../02-xss
docker compose up -d --build
```

---

## 6. Compose File Structure Reference

```yaml
services:
  service-name:
    build: ./path-to-dockerfile-dir   # Local build context
    image: image-tag-name             # Name for the resulting image
    container_name: my-container      # Fixed name for docker exec
    restart: unless-stopped           # Auto-restart policy
    depends_on:
      - other-service                 # Startup ordering
    networks:
      network-name:
        ipv4_address: 10.9.0.x       # Fixed container IP
    ports:
      - "hostPort:containerPort"      # Port forwarding
    environment:
      - VAR=value                     # Environment variables
    volumes:
      - host-path:container-path      # Volume mounts
    tty: true                         # Allocate pseudo-TTY (keeps container alive)

networks:
  network-name:
    name: explicit-network-name       # Name used in 'docker network ls'
    ipam:
      config:
        - subnet: 10.9.0.0/24        # Subnet for container IPs
```
