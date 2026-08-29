# Resource Requirements and Allocation Guide

This document specifies system resource requirements, memory allocation guidelines, and typical consumption metrics when running the Docker SEED Web Security Labs.

---

## 1. System Requirements Tier Matrix

| Tier | Configuration | Hardware Allocation | Recommended Usage |
|------|---------------|---------------------|-------------------|
| **Minimum** | CPU: 4 logical cores<br>RAM: 8 GB<br>Disk: 20 GB free space | Docker Memory: 4 GB<br>Docker CPU: 2-4 cores | Run **one lab environment at a time**. Close unnecessary background host applications. |
| **Recommended** | CPU: 6-8 logical cores<br>RAM: 16 GB<br>Disk: 40 GB free space (SSD) | Docker Memory: 6-8 GB<br>Docker CPU: 4-6 cores | Run multiple lab containers simultaneously alongside VS Code and host web browsers. |
| **Advanced** | CPU: 8+ logical cores<br>RAM: 32 GB<br>Disk: 60+ GB free space (NVMe SSD) | Docker Memory: 12-16 GB<br>Docker CPU: 6+ cores | Run multiple labs, browser developer tools, packet capture tools (Wireshark), and IDEs without constraint. |

---

## 2. Typical Resource Utilization per Component

Actual resource consumption depends on active container count, database query complexity, and browser developer tool tabs.

| Component | Typical Resource Use | Operational Notes |
|-----------|----------------------|-------------------|
| **Docker Engine (`dockerd` / WSL2)** | Low to Moderate | Memory consumption scales with total active containers and volume caches. |
| **Web Server Container (Apache/PHP)** | Moderate (~150 MB - 300 MB RAM) | Idle CPU is < 1%; spikes briefly during script execution. |
| **Database Container (MySQL 8.x)** | Moderate to High (~400 MB - 600 MB RAM) | Pre-allocates buffer pool memory; sensitive to low host RAM. |
| **Host Web Browser (Chrome/Firefox)** | Moderate to High (~500 MB - 2 GB RAM) | DevTools tabs, network recording, and multiple tabs consume host RAM. |
| **VS Code / Code Editor** | Moderate (~300 MB - 1 GB RAM) | Language server extensions and active workspace indexing consume RAM. |

---

## 3. Recommended Optimization Strategies

1. **Run One Lab at a Time on Minimum Systems**: Execute `docker compose down` inside your active lab directory before starting a new lab.
2. **Configure WSL2 Memory Limits on Windows**: Maintain `%USERPROFILE%\.wslconfig` with `memory=8GB` to prevent WSL2 from over-allocating host memory.
3. **Periodically Prune Unused Docker Cache**: Run `./scripts/cleanup.sh` to remove orphaned containers and dangling networks.
