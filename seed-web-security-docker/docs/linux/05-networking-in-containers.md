# Linux Module 05 — Container Networking and Host Resolution

This document details networking utilities, container IP addressing, and DNS resolution inside Docker container bridge networks.

---

## 1. Container Network Isolation

Each SEED lab container attaches to an isolated Docker bridge network (`10.9.0.0/24`). Docker Engine acts as an internal DNS server, resolving container service names to their assigned static IP addresses.

```
       Docker Bridge Network (net-10.9.0.0)
                         |
      +------------------+------------------+
      |                                     |
      v                                     v
+-----------------------+             +-----------------------+
| Web Container         |             | MySQL Container       |
| IP: 10.9.0.5          |             | IP: 10.9.0.6          |
| Hostname: www-10.9.0.5|             | Hostname: mysql-10.9  |
+-----------------------+             +-----------------------+
```

---

## 2. Command Reference

### Command 1: `hostname`

- **What it does**: Prints the container's configured network host name.
- **Why it matters**: Confirms container identity on the Docker network.
- **SEED Lab Application**: Run `hostname` inside `elgg-10.9.0.5` to verify container node name.

### Command 2: `ip addr` (or `ifconfig`)

- **What it does**: Displays active network interfaces, IP addresses (`inet`), broadcast, and subnet mask.
- **Why it matters**: Confirms container IP assignment on the `10.9.0.0/24` subnet.
- **SEED Lab Application**: Run `ip addr` inside `www-10.9.0.5` to confirm its interface `eth0` holds IP `10.9.0.5`.

### Command 3: `getent hosts`

- **What it does**: Queries system name service switch databases (including `/etc/hosts` and Docker embedded DNS).
- **Why it matters**: Verifies how hostnames resolve inside the container.
- **SEED Lab Application**: Run `getent hosts mysql` inside the web container to verify it resolves to `10.9.0.6`.

### Command 4: `ping`

- **What it does**: Sends ICMP ECHO_REQUEST packets to network hosts to test reachability.
- **Why it matters**: Diagnoses container-to-container connectivity issues on the bridge network.
- **SEED Lab Application**: Test connectivity from `elgg-10.9.0.5` to `mysql-10.9.0.6` by running `ping -c 2 10.9.0.6`.
