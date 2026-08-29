# Docker Module 04 — Persistent Volumes and Data Resets

This module covers Docker storage architectures, named volumes, bind mounts, and how database state persistence and resets work across the SEED labs.

---

## 1. Storage Architecture Options

Docker provides three mechanisms for mounting data into containers:

```
+-----------------------------------------------------------------------+
| NAMED VOLUMES                                                         |
| Managed entirely by Docker in host storage (/var/lib/docker/volumes). |
| Best for database persistence (MySQL data directories).               |
+-----------------------------------------------------------------------+

+-----------------------------------------------------------------------+
| BIND MOUNTS                                                           |
| Mounts any file or directory from host filesystem into container.     |
| Best for active code development and mounting SQL initialization scripts.|
+-----------------------------------------------------------------------+

+-----------------------------------------------------------------------+
| TMPFS MOUNTS                                                          |
| Mounts directly into host system memory (RAM). Never written to disk.  |
| Best for high-performance sensitive temporary data.                   |
+-----------------------------------------------------------------------+
```

---

## 2. Named Volumes vs. Bind Mounts in SEED Labs

In `labs/01-sql-injection/docker-compose.yml`:

```yaml
services:
  mysql:
    image: seed-image-mysql-sqli
    container_name: mysql-10.9.0.6
    volumes:
      - mysql-data:/var/lib/mysql        # Named volume for persistent database storage
      - ./image_mysql/sqllab_users.sql:/docker-entrypoint-initdb.d/sqllab_users.sql # Bind mount for initialization script

volumes:
  mysql-data:                             # Declare named volume
```

### How Database Initialization Works
1. When MySQL container starts for the **first time**, `/var/lib/mysql` is empty.
2. The MySQL entrypoint script detects an empty database directory and automatically executes all `.sql` files mounted in `/docker-entrypoint-initdb.d/`.
3. The database tables (`sqllab_users`) and default rows are created and stored inside the `mysql-data` named volume.
4. On subsequent restarts (`docker compose stop` / `docker compose start`), `/var/lib/mysql` is NOT empty, so initialization scripts are skipped, preserving any database changes made during lab tasks.

---

## 3. Volume Management Commands

```bash
# List all Docker volumes on the system
docker volume ls

# Inspect volume details (shows host mount path in JSON)
docker volume inspect net-10.9.0.0-sqli_mysql-data

# Remove a specific unused volume
docker volume rm <volume_name>

# Remove all unused Docker volumes (frees disk space)
docker volume prune
```

---

## 4. Resetting Database State in Labs

When completing attack tasks (e.g., updating employee salaries or modifying user profiles), the database state is changed inside the named volume.

### Partial Reset (Preserve Database)
```bash
# Stops containers but retains the named volume
docker compose down

# Starting again keeps all altered database records
docker compose up -d
```

### Full Data Reset (Restore Initial State)
```bash
# Destroys containers AND deletes named volumes ('-v' flag)
docker compose down -v

# Rebuilds and launches containers, triggering re-execution of .sql init scripts
docker compose up -d --build
```

Verify that the database reset successfully restored original data:
```bash
docker exec -it mysql-10.9.0.6 mysql -u root -pdees -e "SELECT Name, Salary FROM sqllab_users.credential;"
```
