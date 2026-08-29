# Docker Networking — Container-to-Container Communication

This document explains how Docker networks work, how containers find each other, and how host port forwarding works. All SEED labs use Docker bridge networks.

---

## 1. How Container Networking Works

By default, Docker creates an isolated virtual network for each Compose project. Containers on the same network can communicate by IP address. The host machine can reach containers only through mapped ports.

```
HOST MACHINE
  |
  | Port 10080 (host) -> Port 80 (container www-10.9.0.5)
  |
  Docker Bridge Network: 10.9.0.0/24
    |
    +---- 10.9.0.5   www container    (Apache + PHP)
    |
    +---- 10.9.0.6   mysql container  (MySQL 8.0)

The containers can reach each other at their static IPs.
The host can reach the web server at localhost:10080.
The host cannot reach MySQL directly (no port mapping = no host access).
```

---

## 2. Inspect Networks

```bash
# List all Docker networks
docker network ls

# Inspect a specific network — shows subnet, gateway, and connected containers with IPs
docker network inspect net-10.9.0.0-sqli

# Show the IP of a specific container
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' www-10.9.0.5
```

---

## 3. Container-to-Container Communication

Containers on the same Docker network reach each other by IP address. In docker-compose.yml, static IPs are assigned using `ipv4_address`.

```bash
# Test connectivity from web container to MySQL container
docker exec -it www-10.9.0.5 bash

# Inside the container:
ping 10.9.0.6          # Should receive ICMP replies
curl http://10.9.0.6   # MySQL doesn't serve HTTP, but confirms TCP routing

# Test MySQL TCP port from web container
mysql -h 10.9.0.6 -u root -pdees sqllab_users

exit
```

---

## 4. Host Port Mapping

Port mapping (`ports:` in docker-compose.yml) creates a forwarding rule:

```yaml
ports:
  - "10080:80"    # Host port 10080 -> Container port 80
```

```bash
# Verify port mapping is active
docker compose ps
# Shows: 0.0.0.0:10080->80/tcp

# Test from host
curl.exe http://localhost:10080            # Windows
curl http://localhost:10080               # Linux/macOS

# Check what process is listening on a host port
netstat -ano | findstr :10080             # Windows
ss -tlnp | grep :10080                   # Linux
```

---

## 5. Network Isolation Between Labs

Each lab uses a different named network to prevent cross-lab interference:

| Lab | Network Name | Subnet |
|-----|-------------|--------|
| 01 SQL Injection | `net-10.9.0.0-sqli` | `10.9.0.0/24` |
| 02 XSS | `net-10.9.0.0-xss` | `10.9.0.0/24` |
| 03 CSRF | `net-10.9.0.0-csrf` | `10.9.0.0/24` |
| 04 Clickjacking | `net-10.9.0.0-clickjacking` | `10.9.0.0/24` |
| 05 Shellshock | `net-10.9.0.0-shellshock` | `10.9.0.0/24` |

Running two labs simultaneously may cause a subnet conflict because they all use `10.9.0.0/24`. Stop one before starting another:

```bash
# Stop Lab 01 before starting Lab 02
cd labs/01-sql-injection && docker compose down
cd ../02-xss && docker compose up -d --build
```

---

## 6. Hosts File — Domain Name Resolution

The SEED lab tasks use domain names (`www.seed-server.com`) instead of `localhost:10080`. The hosts file provides local DNS override without a real DNS server.

```
Browser looks up www.seed-server.com
  -> OS checks /etc/hosts (or C:\Windows\System32\drivers\etc\hosts)
  -> Finds: 10.9.0.5  www.seed-server.com
  -> Sends HTTP request to 10.9.0.5
  -> Docker intercepts and routes to the www container
```

```bash
# View current hosts file (Linux)
cat /etc/hosts

# Add entry (Linux/WSL2 — requires sudo)
echo "10.9.0.5   www.seed-server.com" | sudo tee -a /etc/hosts

# Verify hostname resolves
ping www.seed-server.com
curl http://www.seed-server.com
```

```powershell
# Windows — view hosts file
Get-Content "C:\Windows\System32\drivers\etc\hosts"

# Add entry (run PowerShell as Administrator)
Add-Content "C:\Windows\System32\drivers\etc\hosts" "10.9.0.5   www.seed-server.com"

# Verify
ping www.seed-server.com
curl.exe http://www.seed-server.com
```
