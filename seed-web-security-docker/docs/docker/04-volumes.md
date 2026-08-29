# Docker Module 04 — Storage and Volumes

This document covers Docker volumes, bind mounts, data persistence, and database state management.

---

## 1. Storage Options in Docker

Data inside a container's writable layer is temporary and destroyed when the container is removed. Docker volumes provide persistent storage detached from the container lifecycle.

```
Container (mysql-10.9.0.6)
  |
  +-- /var/lib/mysql  (Mount Point)
           |
           v
Docker Named Volume / Host Storage
  (Data persists even when container is deleted)
```

---

## 2. Volume Management Commands

```bash
# List volumes
docker volume ls

# Inspect volume host mount point
docker volume inspect <volume_name>

# Remove unused volumes
docker volume prune
```

### SEED Lab Reset Behavior
Running `docker compose down` removes containers but preserves volumes. Running `docker compose down -v` deletes named volumes, resetting MySQL databases back to their clean initial state.
