# Documentation Module 06 — Resource Allocation and Disk Management

This module details expected hardware resource utilization per lab and provides procedures for inspecting and pruning Docker disk usage.

---

## 1. Resource Consumption Metrics per Lab

| Lab | Active Containers | Peak RAM Usage | Disk Usage (Images) | CPU Usage (Idle/Peak) |
|-----|-------------------|----------------|---------------------|-----------------------|
| 01 SQL Injection | 2 (web, mysql) | ~600 MB | ~1.5 GB | < 1% / ~15% |
| 02 XSS | 2 (elgg, mysql) | ~700 MB | ~2.0 GB | < 1% / ~20% |
| 03 CSRF | 3 (elgg, attacker, mysql) | ~850 MB | ~2.5 GB | < 1% / ~25% |
| 04 Clickjacking | 2 (target, attacker) | ~200 MB | ~500 MB | < 1% / ~5% |
| 05 Shellshock | 1 (web) | ~150 MB | ~500 MB | < 1% / ~5% |

---

## 2. Disk Space Storage Breakdown

Docker disk usage consists of four components:
```
Total Docker Usage = Container Writable Layers + Images + Volumes + Build Cache
```

### Safe Inspection Commands
```bash
# Display overview of Docker disk usage
docker system df

# List all downloaded images with sizes
docker image ls

# List active containers
docker ps -a

# List persistent volumes
docker volume ls
```

---

## 3. Recommended Pruning Procedures

### Level 1: Stopped Containers & Unused Networks (Non-destructive)
```bash
docker container prune -f
docker network prune -f
```

### Level 2: Comprehensive Environment Cleanup (Preserves Downloaded Images)
Use the included project script:
```bash
./scripts/cleanup.sh
```

### Level 3: Deep Prune (Removes All SEED Images & Cache)
Warning: Next lab execution will require re-downloading images (~5-10 GB total).
```bash
./scripts/cleanup.sh --all
```
Or manually:
```bash
docker system prune -a --volumes -f
```
