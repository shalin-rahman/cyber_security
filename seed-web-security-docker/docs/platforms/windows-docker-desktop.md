# Windows Setup — Docker Desktop with WSL2

This guide covers every step needed to run SEED Web Security labs on Windows 10 or Windows 11 using Docker Desktop. No Linux VM is required.

---

## Architecture Overview

On Windows, Docker Desktop installs a lightweight Linux virtual machine using WSL2 (Windows Subsystem for Linux 2). All Docker containers run inside this Linux VM. Your Windows PowerShell terminal communicates with Docker through a named pipe provided by Docker Desktop.

```
Windows 10/11 Host
+---------------------------------------------+
| PowerShell or Windows Terminal              |
| docker CLI -> Docker Desktop (named pipe)   |
+---------------------------------------------+
| WSL2 Hypervisor (Hyper-V core)              |
| +-------------------------------------------+|
| | Linux Kernel (WSL2 VM)                   ||
| | Docker Engine (dockerd)                  ||
| |                                          ||
| |  +------------------+ +----------------+ ||
| |  | Container: www   | | Container:     | ||
| |  | 10.9.0.5         | | mysql 10.9.0.6 | ||
| |  | Apache + PHP     | | MySQL 8.0      | ||
| |  +------------------+ +----------------+ ||
| +-------------------------------------------+|
+---------------------------------------------+
```

Port mapping: a request to `localhost:10080` on Windows passes through WSL2 to the container at port 80.

---

## Part 1 — Prerequisites

### 1.1 Hardware Requirements

- CPU with virtualization support (Intel VT-x or AMD-V)
- At least 8 GB RAM (4 GB free for containers)
- At least 20 GB free disk space
- Windows 10 version 1903 build 18362 or later, or Windows 11

### 1.2 Check Windows Version

Open PowerShell and run:

```powershell
# Check Windows version and build number
[System.Environment]::OSVersion.Version
winver
```

### 1.3 Enable Virtualization (if not already enabled)

Check if virtualization is enabled:

```powershell
# Should show True
(Get-WmiObject Win32_Processor).VirtualizationFirmwareEnabled
```

If it shows False, you must enable VT-x or AMD-V in your BIOS/UEFI firmware settings before continuing. The exact steps depend on your motherboard manufacturer.

---

## Part 2 — Install Docker Desktop

### 2.1 Download

Download Docker Desktop from: https://www.docker.com/products/docker-desktop/

Select the Windows installer (`.exe`).

### 2.2 Install

Run the installer. During installation:
- Select "Use WSL 2 instead of Hyper-V" (recommended and required for WSL2 backend)
- Keep "Add shortcut to desktop" if desired
- Restart Windows when prompted

### 2.3 First Launch

After restarting, launch Docker Desktop from the Start menu or desktop shortcut.

Wait for the whale icon in the system tray (bottom-right of taskbar) to stop animating. When the icon is steady, the Docker Engine is running.

### 2.4 Verify Installation

Open PowerShell (does not need to be Administrator for this step):

```powershell
# Check Docker client and server version
docker version

# Expected output shows both Client and Server sections.
# If only Client shows and Server is missing, Docker Desktop is not running yet.

# Check Docker daemon status and resource allocation
docker info

# Run a test container that prints "Hello from Docker" and exits
docker run hello-world

# Verify Docker Compose is available
docker compose version
```

---

## Part 3 — Configure the Hosts File

The SEED labs use domain names like `www.seed-server.com` that must resolve to the Docker container's IP address. The Windows hosts file provides this local DNS override.

### 3.1 Open PowerShell as Administrator

Right-click the PowerShell icon in the Start menu and select "Run as administrator". This is required to modify the hosts file.

### 3.2 View the Current Hosts File

```powershell
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
Get-Content $hostsFile
```

### 3.3 Add All Lab Hostname Entries

```powershell
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"

# Add entries for all five labs
$entries = @(
    "10.9.0.5     www.seed-server.com",
    "10.9.0.105   www.attacker32.com",
    "10.9.0.80    www.cjlab.com",
    "10.9.0.81    www.cjlab-attacker.com"
)

foreach ($entry in $entries) {
    $host = ($entry -split '\s+')[1]
    if (-not (Select-String -Path $hostsFile -Pattern $host -Quiet)) {
        Add-Content -Path $hostsFile -Value $entry
        Write-Host "Added: $entry" -ForegroundColor Green
    } else {
        Write-Host "Already present: $host" -ForegroundColor Yellow
    }
}
```

### 3.4 Verify Hostname Resolution

```powershell
# After starting Lab 01, test that the hostname resolves
ping www.seed-server.com

# Should reply from 10.9.0.5
# If "could not find host", check the hosts file entry was added
Get-Content "C:\Windows\System32\drivers\etc\hosts" | Select-String "seed"
```

---

## Part 4 — Run Lab 01 (Full Step-by-Step)

### Layer 1 — Docker Commands on Windows PowerShell

```powershell
# Navigate to Lab 01 directory
cd C:\Users\YourName\workstation\shaleen\iit\cyber_security\seed-web-security-docker\labs\01-sql-injection

# Build images from local Dockerfiles and start containers in background
docker compose up -d --build

# What this does:
# 1. Reads docker-compose.yml
# 2. Builds image_www/Dockerfile -> Apache + PHP + vulnerable PHP app
# 3. Builds image_mysql/Dockerfile -> MySQL 8.0 + pre-loaded sqllab_users database
# 4. Creates isolated Docker bridge network (10.9.0.0/24)
# 5. Starts www-10.9.0.5 at 10.9.0.5, maps host port 10080 to container port 80
# 6. Starts mysql-10.9.0.6 at 10.9.0.6

# Verify containers are running
docker compose ps

# Expected:
# NAME             IMAGE                   STATUS    PORTS
# www-10.9.0.5     seed-image-www-sqli     Up        0.0.0.0:10080->80/tcp
# mysql-10.9.0.6   seed-image-mysql-sqli   Up        3306/tcp
```

```powershell
# View container logs in real time
docker compose logs -f

# Press Ctrl+C to stop streaming
```

```powershell
# Inspect Docker network to see container IPs
docker network inspect net-10.9.0.0-sqli

# Show individual container IP
docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" www-10.9.0.5
# Output: 10.9.0.5
```

```powershell
# Test HTTP access from PowerShell (use curl.exe, not curl alias)
curl.exe -I http://localhost:10080
# Should return: HTTP/1.1 200 OK
```

### Layer 2 — Linux Commands (inside the container)

Open a bash shell inside the web container:

```powershell
docker exec -it www-10.9.0.5 bash
```

Your PowerShell prompt changes to the container Linux prompt:
```
Before: PS C:\Users\YourName>
After:  root@www-10.9.0.5:/#
```

You are now inside the container's Linux environment. Run Linux commands:

```bash
# Check identity
whoami
# root

id
# uid=0(root) gid=0(root) groups=0(root)

# Check hostname matches container_name in docker-compose.yml
hostname
# www-10.9.0.5

# Check the container's IP on the Docker network
ip addr show
# eth0 should show 10.9.0.5/24

# Navigate to web application root
cd /var/www/html

# List the PHP application files
ls -la

# Read the vulnerable PHP source code
cat index.php

# Find SQL query construction lines
grep -n "SELECT\|UPDATE" index.php

# Check running processes (Apache master + workers)
ps aux

# Check environment variables (look for MYSQL_HOST)
env

# Check Apache is listening on port 80
ss -tlnp

# View Apache access log
tail -f /var/log/apache2/access.log
# Press Ctrl+C to stop

# Test connectivity to MySQL container
ping -c 3 10.9.0.6

# Connect to MySQL from inside the web container
mysql -h 10.9.0.6 -u root -pdees sqllab_users
# Inside MySQL:
SHOW TABLES;
DESCRIBE credential;
SELECT Name, Salary FROM credential;
EXIT;
```

Exit the container back to PowerShell:

```bash
exit
```

Your prompt returns:
```
Before: root@www-10.9.0.5:/#
After:  PS C:\Users\YourName>
```

```powershell
# Enter the MySQL container directly
docker exec -it mysql-10.9.0.6 bash
```

Inside the MySQL container:
```bash
mysql -u root -pdees
USE sqllab_users;
SELECT * FROM credential;
EXIT;
exit
```

### Layer 3 — Security Tasks (browser)

Open your browser and navigate to:

```
http://localhost:10080          direct — always works on Windows
http://www.seed-server.com      works if hosts file was configured in Part 3
```

Perform the lab tasks from the official SEED manual.

After performing injections, verify database changes from PowerShell:

```powershell
# Check database state from host without entering container
docker exec -it mysql-10.9.0.6 mysql -u root -pdees -e "SELECT Name, Salary FROM sqllab_users.credential;"
```

---

## Part 5 — Using curl.exe for HTTP Tests (Lab 02 XSS, Lab 05 Shellshock)

PowerShell aliases `curl` to `Invoke-WebRequest` which does not behave like Unix curl. Always use `curl.exe` explicitly for HTTP testing:

```powershell
# Correct: uses the real curl binary
curl.exe http://localhost:10080

# Shellshock exploit test (Lab 05)
curl.exe -A "() { :; }; echo; echo Content-Type: text/plain; echo; id" `
  http://localhost:10086/cgi-bin/vul.cgi

# Wrong: Invoke-WebRequest does not support -A or raw header injection
# curl -A "..." http://...     <- this errors in PowerShell
```

---

## Part 6 — Stop and Reset

```powershell
# Stop containers, preserve database volumes (resume later)
docker compose down

# Full reset: destroy database volumes, rebuild from sqllab_users.sql
docker compose down -v
docker compose up -d --build
```

Verify the reset restored original data:

```powershell
docker exec -it mysql-10.9.0.6 mysql -u root -pdees `
  -e "SELECT Name, Salary FROM sqllab_users.credential;"
# All salaries back to original values
```

---

## Part 7 — Cleanup After Finishing Labs

```powershell
# Show Docker disk usage
docker system df

# Remove stopped containers, unused networks, dangling images
docker system prune

# Remove all unused images too (frees more space)
docker system prune -a

# Or use the repo cleanup script
.\scripts\cleanup.ps1           # stops containers and removes networks
.\scripts\cleanup.ps1 -All     # also removes images and build cache
```

---

## Common Issues on Windows

### Docker Desktop is not running

The Docker daemon only runs when Docker Desktop is open. Open Docker Desktop from the Start menu before running any `docker` commands. Wait for the system tray whale icon to become steady (not animating).

```powershell
# Check if Docker is responding
docker info
# Error output means Docker Desktop is not running
```

### Port already in use

If a lab port like 10080 is already occupied:

```powershell
# Find which process is using port 10080
netstat -ano | findstr :10080

# Kill that process by PID
taskkill /PID <pid> /F

# Or stop the conflicting lab first
cd labs\01-sql-injection
docker compose down
```

### PowerShell script execution blocked

```powershell
# Allow locally created scripts to run for the current user
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### Hosts file cannot be modified

Must run PowerShell as Administrator. Right-click PowerShell in the Start menu and select "Run as administrator" before running the hosts file configuration commands.

### curl fails with parameter errors

```powershell
# Error: "A parameter cannot be found that matches parameter name 'sI'"
# This happens when using the PowerShell curl alias

# Fix: always use curl.exe explicitly
curl.exe -I http://localhost:10080
```

### WSL2 not installed or outdated

```powershell
# Install or update WSL2 kernel
wsl --update

# Check WSL version
wsl --list --verbose
```

### Container exits immediately after start

```powershell
# Check why the container stopped
docker compose logs www
docker compose logs mysql

# Common causes:
# - MySQL port conflict with a running MySQL service on host
# - Missing build context (Dockerfile or source files)
# - Image build failed silently
```

### Not enough memory

Docker Desktop defaults to using 50% of system RAM for WSL2. If containers keep crashing:

1. Open Docker Desktop
2. Go to Settings -> Resources -> Memory
3. Increase to at least 4 GB
4. Apply and Restart
