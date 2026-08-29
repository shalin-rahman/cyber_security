# Docker Module 05 — Multi-Container Orchestration with Docker Compose

This document covers declarative multi-container specification using `docker-compose.yml` for SEED security labs.

---

## 1. Docker Compose Structure

Docker Compose orchestrates multi-container applications including web servers, databases, and network configurations in a single declarative YAML file.

```yaml
version: "3"

services:
  www:
    image: handsonsecurity/seed-image-www-sqli
    container_name: www-10.9.0.5
    depends_on:
      - mysql
    networks:
      net-10.9.0.0:
        ipv4_address: 10.9.0.5
    ports:
      - "10080:80"

  mysql:
    image: handsonsecurity/seed-image-mysql-sqli
    container_name: mysql-10.9.0.6
    networks:
      net-10.9.0.0:
        ipv4_address: 10.9.0.6

networks:
  net-10.9.0.0:
    name: net-10.9.0.0-sqli
    ipam:
      config:
        - subnet: 10.9.0.0/24
```

---

## 2. Essential Docker Compose Commands

```bash
# Build/pull and start all services in background
docker compose up -d

# Check service status
docker compose ps

# View aggregated logs
docker compose logs -f

# Stop and remove containers and networks
docker compose down

# Stop containers and remove volumes (reset database)
docker compose down -v
```
