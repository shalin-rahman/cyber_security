# Documentation Module 03 — SEED Lab Network Architecture

This module documents the network topology, IP addressing, host port mapping, and DNS resolution mechanism across all five SEED web security labs.

---

## 1. Network Topology Overview

Each lab provisions an isolated Docker custom bridge network on the `10.9.0.0/24` subnet.

```
       +-------------------------------------------------------------+
       |                      Host Computer                          |
       |                                                             |
       |  Browser requests: http://www.seed-server.com               |
       |  Host DNS (/etc/hosts) maps www.seed-server.com -> 10.9.0.5 |
       +------------------------------+------------------------------+
                                      |
                               Port forwarding
                          (e.g., 10080:80, 10081:80)
                                      |
       +------------------------------v------------------------------+
       |                  Isolated Lab Bridge Network                |
       |                        (10.9.0.0/24)                        |
       |                                                             |
       |    +-------------------+           +-------------------+    |
       |    |   Web Container   |           | Database Container|    |
       |    |    (10.9.0.5)     +----------->    (10.9.0.6)     |    |
       |    +-------------------+           +-------------------+    |
       +-------------------------------------------------------------+
```

---

## 2. Complete Lab Network Specification

| Lab | Container Name | Service Role | Subnet | Container IP | Host Access Port | Hostname |
|-----|----------------|--------------|--------|--------------|------------------|----------|
| **01 SQLi** | `www-10.9.0.5` | Apache/PHP Web App | `10.9.0.0/24` | `10.9.0.5` | `10080` | `www.seed-server.com` |
| | `mysql-10.9.0.6` | MySQL 8.x Database | `10.9.0.0/24` | `10.9.0.6` | None (Internal) | N/A |
| **02 XSS** | `elgg-10.9.0.5` | Elgg Social Network | `10.9.0.0/24` | `10.9.0.5` | `10081` | `www.seed-server.com` |
| | `mysql-10.9.0.6-xss` | Elgg MySQL DB | `10.9.0.0/24` | `10.9.0.6` | None (Internal) | N/A |
| **03 CSRF** | `elgg-10.9.0.5-csrf` | Target Elgg Site | `10.9.0.0/24` | `10.9.0.5` | `10082` | `www.seed-server.com` |
| | `attacker-10.9.0.105` | Attacker Server | `10.9.0.0/24` | `10.9.0.105` | `10083` | `www.attacker32.com` |
| | `mysql-10.9.0.6-csrf` | Elgg DB | `10.9.0.0/24` | `10.9.0.6` | None (Internal) | N/A |
| **04 Clickjacking** | `cjlab-10.9.0.80` | Target Web Site | `10.9.0.0/24` | `10.9.0.80` | `10084` | `www.cjlab.com` |
| | `cjlab-attacker-10.9.0.81` | Attacker Overlay | `10.9.0.0/24` | `10.9.0.81` | `10085` | `www.cjlab-attacker.com` |
| **05 Shellshock** | `shellshock-10.9.0.80` | Apache CGI Server | `10.9.0.0/24` | `10.9.0.80` | `10086` | `www.seedlab-shellshock.com` |

---

## 3. Hostname Resolution Mechanics

1. When a browser initiates a request to `http://www.seed-server.com`, the OS checks the local hosts file before querying DNS servers.
2. The hosts file resolves `www.seed-server.com` to `10.9.0.5` (or `127.0.0.1` when port forwarding is used).
3. The HTTP GET request reaches the web container's Apache instance. Apache inspects the `Host:` header (`Host: www.seed-server.com`) and routes the request to the correct virtual host block.
