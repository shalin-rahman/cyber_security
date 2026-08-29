# Platform Setup: Ubuntu Linux with Native Docker Engine

This guide documents the system architecture, installation steps, user group permissions, and command execution flow for running the SEED Web Security Docker environment natively on Ubuntu Linux.

---

## 1. System Architecture

On native Ubuntu Linux, Docker runs directly on the host Linux kernel without any virtual machine, hypervisor, or emulation layer.

```
+-------------------------------------------------------------------+
|                        Ubuntu Host Machine                        |
|  Native Linux Kernel (Host OS)                                    |
|                                                                   |
|  +-------------------------------------------------------------+  |
|  |                 Docker Engine (dockerd)                     |  |
|  |                                                             |  |
|  |   +------------------------+   +------------------------+   |  |
|  |   |  Web App Container     |   |  Database Container    |   |  |
|  |   |  (Apache / PHP)        |   |  (MySQL 8.x)           |   |  |
|  |   +-----------+------------+   +-----------+------------+   |  |
|  |               |                        |                    |  |
|  |               +--- Docker Network -----+                    |  |
|  |                    (net-10.9.0.0)                           |  |
|  +-------------------------------------------------------------+  |
+-------------------------------------------------------------------+
```

---

## 2. Host Command Execution vs Container Command Execution

It is essential to distinguish between commands executed on the Ubuntu host system and commands executed inside a running Docker container.

```
[Ubuntu Host Terminal]
$ docker ps                         <-- Executed on Ubuntu Host OS
$ docker exec -it elgg-10.9.0.5 bash  <-- Initiates session into container

[Inside Container Shell]
root@elgg-10.9.0.5:/# ps aux        <-- Inspects processes inside Container
root@elgg-10.9.0.5:/# whoami        <-- Checks user identity inside Container
```

### Context Distinction Table

| Command Context | Command Example | Where Execution Occurs | What Is Returned |
|-----------------|-----------------|------------------------|------------------|
| **Host Terminal** | `docker ps` | Ubuntu Host OS | Active container instances |
| **Host Terminal** | `docker compose up -d` | Ubuntu Host OS | Starts container environment |
| **Container Shell** | `pwd` | Container User Space | Current directory in container filesystem |
| **Container Shell** | `ps aux` | Container Process Space | Processes inside that specific container |
| **Container Shell** | `cat /etc/passwd` | Container User Space | User accounts inside container |

---

## 3. Installation Guide for Ubuntu

### Step 1: Remove Conflicting Packages
```bash
sudo apt-get remove -y docker docker-engine docker.io containerd runc
```

### Step 2: Set Up Official Docker Repository
```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Step 3: Install Docker Engine and Compose Plugin
```bash
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Step 4: Configure Non-Root User Permissions
To run `docker` commands without `sudo`:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## 4. Hostname Configuration on Ubuntu

Edit `/etc/hosts` on the Ubuntu host:
```bash
sudo tee -a /etc/hosts << 'EOF'
# SEED Web Security Host Mappings
10.9.0.5    www.seed-server.com
10.9.0.105  www.attacker32.com
10.9.0.80   www.cjlab.com
10.9.0.81   www.cjlab-attacker.com
10.9.0.80   www.seedlab-shellshock.com
EOF
```

Verify mapping:
```bash
ping -c 1 www.seed-server.com
```
