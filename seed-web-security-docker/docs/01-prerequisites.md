# Documentation Module 01 — System Prerequisites and Installation

This module provides hardware, software, and configuration requirements for setting up the Docker-based SEED Web Security Lab environment.

---

## 1. Hardware Requirements

### Minimum Configuration
- CPU: 4 logical cores minimum
- RAM: 8 GB minimum
- Free Disk Space: 20 GB minimum
- Network: Internet connection for initial container image downloads

### Recommended Configuration
- CPU: 6 to 8 logical cores
- RAM: 16 GB
- Free Disk Space: 40 GB free space (SSD recommended)
- Docker Memory Allocation: 6 to 8 GB allocated to Docker Engine / WSL2

---

## 2. Software Installation Guides

### Target Platform 1: Windows 10 / Windows 11 (Primary Target)

1. **Install WSL2 (Windows Subsystem for Linux)**
   Open PowerShell as Administrator and execute:
   ```powershell
   wsl --install
   wsl --set-default-version 2
   ```
   Reboot the system if prompted.

2. **Install Docker Desktop**
   - Download installer: https://docs.docker.com/desktop/install/windows-install/
   - During installation, verify that "Use WSL 2 instead of Hyper-V" is checked.
   - Launch Docker Desktop after installation completes.

3. **Configure WSL2 Resource Allocation (`.wslconfig`)**
   Create or edit `%USERPROFILE%\.wslconfig` to allocate sufficient RAM and CPU to the Docker WSL2 backend:
   ```ini
   [wsl2]
   memory=8GB
   processors=4
   swap=2GB
   localhostForwarding=true
   ```
   Restart WSL2 via PowerShell:
   ```powershell
   wsl --shutdown
   ```

4. **Install Supporting Utilities**
   - Git: https://git-scm.com/download/win
   - VS Code: https://code.visualstudio.com/
   - Browser: Firefox or Chrome

---

### Target Platform 2: Ubuntu Linux (Secondary Target)

1. **Uninstall Legacy Packages**
   ```bash
   sudo apt-get remove docker docker-engine docker.io containerd runc
   ```

2. **Install Docker Engine & Docker Compose Plugin via Official Repository**
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

   sudo apt-get update
   sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```

3. **Configure User Permissions**
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

---

### Target Platform 3: macOS (Optional Target)

1. **Install Docker Desktop for Mac**
   - Apple Silicon (M1/M2/M3): Download Mac with Apple chip installer.
   - Intel Mac: Download Mac with Intel chip installer.
   - Link: https://docs.docker.com/desktop/install/mac-install/

2. **ARM64 Architecture Note**
   Official SEED container images are built for AMD64 (`linux/amd64`). Docker Desktop on Apple Silicon uses Rosetta 2 / QEMU emulation. Performance may be degraded during heavy DB initialization.

---

## 3. Hostname Resolution Setup (`/etc/hosts`)

SEED web security labs rely on hostnames rather than raw IP addresses due to session cookie scoping.

### Summary of Hostname Mappings

| Lab | Hostname | IP Address |
|-----|----------|------------|
| 01 SQL Injection | `www.seed-server.com` | `10.9.0.5` |
| 02 XSS | `www.seed-server.com` | `10.9.0.5` |
| 03 CSRF | `www.seed-server.com` | `10.9.0.5` |
| 03 CSRF Attacker | `www.attacker32.com` | `10.9.0.105` |
| 04 Clickjacking Target | `www.cjlab.com` | `10.9.0.80` |
| 04 Clickjacking Attacker | `www.cjlab-attacker.com` | `10.9.0.81` |
| 05 Shellshock | `www.seedlab-shellshock.com` | `10.9.0.80` |

### Adding Entries on Linux / macOS / WSL2
```bash
sudo tee -a /etc/hosts << 'EOF'
10.9.0.5    www.seed-server.com
10.9.0.105  www.attacker32.com
10.9.0.80   www.cjlab.com
10.9.0.81   www.cjlab-attacker.com
10.9.0.80   www.seedlab-shellshock.com
EOF
```

### Adding Entries on Windows
Run PowerShell as Administrator:
```powershell
$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$entries = @"
10.9.0.5    www.seed-server.com
10.9.0.105  www.attacker32.com
10.9.0.80   www.cjlab.com
10.9.0.81   www.cjlab-attacker.com
10.9.0.80   www.seedlab-shellshock.com
"@
Add-Content -Path $hostsPath -Value $entries
```
