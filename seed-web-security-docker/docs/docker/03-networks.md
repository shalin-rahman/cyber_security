# Docker Module 03 — Container Networks

This document details Docker bridge networking, static IP assignment, container DNS resolution, and host port forwarding.

---

## 1. Network Driver Architecture

Docker provides multiple network drivers. SEED labs use custom user-defined **bridge networks**.

```
Host Network Interface
        |
   Port Forwarding (10080 -> 80)
        |
Docker Bridge Network (net-10.9.0.0, Subnet: 10.9.0.0/24)
        |
        +--- Container A: www-10.9.0.5  (10.9.0.5)
        |
        +--- Container B: mysql-10.9.0.6 (10.9.0.6)
```

---

## 2. Features of Custom Bridge Networks

1. **Automatic DNS Resolution**: Containers on a custom bridge network resolve each other by container name or service name (e.g., `mysql` resolves to `10.9.0.6`).
2. **Static IP Assignment**: Allows assigning explicit IP addresses (`10.9.0.5`) to match SEED lab documentation.
3. **Network Isolation**: Independent bridge networks (`net-10.9.0.0-sqli`, `net-10.9.0.0-xss`) keep lab traffic separate.

---

## 3. Command Reference

```bash
# List Docker networks
docker network ls

# Inspect specific lab network configuration
docker network inspect net-10.9.0.0-sqli

# Manually connect/disconnect a container
docker network connect net-10.9.0.0-sqli <container_name>
docker network disconnect net-10.9.0.0-sqli <container_name>
```
