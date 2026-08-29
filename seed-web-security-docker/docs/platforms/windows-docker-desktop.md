# Platform Setup: Windows 10 / 11 with Docker Desktop and WSL2

This guide documents the architecture, setup requirements, resource management, and command execution flow for running the SEED Web Security Docker environment on Windows 10 or Windows 11 without VMware or VirtualBox.

---

## 1. System Architecture

On Windows, Docker Desktop utilizes the Windows Subsystem for Linux 2 (WSL2) backend. The host machine runs Windows, while Docker Engine executes within a lightweight utility VM running a native Linux kernel.

```
+-------------------------------------------------------------------+
|                        Windows Host Machine                       |
|  Windows 10 / 11 (Host OS)                                        |
|                                                                   |
|  +-------------------------------------------------------------+  |
|  |                       Docker Desktop                        |  |
|  |                                                             |  |
|  |  +-------------------------------------------------------+  |  |
|  |  |                   WSL2 Linux Backend                  |  |  |
|  |  |  Native Linux Kernel Environment                      |  |  |
|  |  |                                                       |  |  |
|  |  |  +-------------------------------------------------+  |  |  |
|  |  |  |                 Docker Engine                   |  |  |  |
|  |  |  |                                                 |  |  |  |
|  |  |  |   +------------------+   +------------------+   |  |  |  |
|  |  |  |   |  Elgg Container  |   | MySQL Container  |   |  |  |  |
|  |  |  |   +------------------+   +------------------+   |  |  |  |
|  |  |  +-------------------------------------------------+  |  |  |
|  |  +-------------------------------------------------------+  |  |
|  +-------------------------------------------------------------+  |
+-------------------------------------------------------------------+
```

---

## 2. Command Execution Flow

Commands issued in Windows Terminal pass through Docker Desktop to the Docker Engine inside WSL2, which then executes the shell inside the target Linux container.

```
Windows Terminal (PowerShell / CMD)
  |
  | Command: docker exec -it elgg-10.9.0.5 bash
  v
Docker Engine (running inside WSL2 Linux distribution)
  |
  | Spawns interactive bash process inside container
  v
Linux Shell inside Container (elgg-10.9.0.5)
  |
  | Execute Linux commands: pwd, ls, ps aux, whoami
  v
Container User-Space Execution
```

---

## 3. Installation and Configuration Requirements

### Prerequisites
- Windows 10 64-bit (Build 19041 or higher) or Windows 11
- Hardware Virtualization enabled in BIOS/UEFI (Intel VT-x / AMD-V)

### Step 1: Enable WSL2
Open PowerShell as Administrator:
```powershell
wsl --install
wsl --set-default-version 2
```

### Step 2: Install Docker Desktop
1. Download installer from official Docker documentation: https://docs.docker.com/desktop/install/windows-install/
2. Run installer and select **Use WSL 2 instead of Hyper-V**.
3. Complete installation and restart system if requested.

### Step 3: Configure Resource Limits via `.wslconfig`
To ensure Docker and WSL2 have sufficient RAM and CPU for database and web containers, create `%USERPROFILE%\.wslconfig`:

```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
localhostForwarding=true
```

Apply settings by restarting WSL in PowerShell:
```powershell
wsl --shutdown
```

---

## 4. Hostname Configuration on Windows

SEED web security labs rely on hostnames for proper HTTP session cookie domain scoping.

Location of hosts file on Windows:
`C:\Windows\System32\drivers\etc\hosts`

### Adding Host Entries via PowerShell (Administrator)
```powershell
$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$entries = @"
# SEED Web Security Labs Host Mappings
10.9.0.5    www.seed-server.com
10.9.0.105  www.attacker32.com
10.9.0.80   www.cjlab.com
10.9.0.81   www.cjlab-attacker.com
10.9.0.80   www.seedlab-shellshock.com
"@
Add-Content -Path $hostsPath -Value $entries
```

---

## 5. Browser Access and Verification

1. Open your Windows web browser (Chrome, Firefox, or Edge).
2. Navigate to the mapped hostname (e.g., `http://www.seed-server.com`).
3. Port forwarding maps host traffic to the container network, allowing host browsers to interact directly with containerized web applications.
