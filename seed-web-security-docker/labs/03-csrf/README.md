# Lab 03 — Cross-Site Request Forgery (CSRF) Attack Lab

**Implementation Type**: Official SEED source adapted for Docker

Official lab manual: https://seedsecuritylabs.org/Labs_20.04/Web/Web_CSRF_Elgg/
Textbook: Chapter 10 — Cross-Site Request Forgery (*Computer & Internet Security*, 2nd Ed., Prof. Wenliang Du)
Lecture Sync Sitemap: [SEED Lecture & Reference Sitemap](../../docs/lectures-and-references.md#4-lab-03--cross-site-request-forgery-csrf)
CWE Reference: [CWE-352: Cross-Site Request Forgery (CSRF)](https://cwe.mitre.org/data/definitions/352.html)

For authorized educational use only.

> **HOST BROWSER ROUTING NOTICE**: Access Target site in host browsers via `http://localhost:10082` (or `http://www.seed-server.com:10082`) and Attacker site via `http://localhost:10083` (or `http://www.attacker32.com:10083`). Do not use internal container IPs `10.9.0.5` or `10.9.0.105` directly in host browsers.  
> **CONTAINER COMMAND FALLBACKS**: If `bash` is missing: `docker exec -it elgg-10.9.0.5-csrf sh`. If `ip` is missing: `hostname -i`. If `ss` is missing: `netstat -tlnp`.

---

## Security Concept

### The Security Hole
The target web application relies on session cookies for authentication and does **not** verify the origin of state‑changing requests. Browsers automatically include stored cookies on any request to the target domain, even when the request originates from a different site.

### How it Causes a Problem
An attacker can host a malicious page on a separate domain (e.g., `www.attacker32.com`). When a victim who is logged into the target site (`www.seed-server.com`) visits the malicious page, the attacker’s page can silently issue forged HTTP requests (GET or POST) to the target site. Because the browser attaches the victim’s authentication cookie, the target server processes the request as if it originated from the victim, allowing actions such as adding friends, changing settings, or performing transactions without the victim’s consent.

```
Alice logs into www.seed-server.com → Browser stores session cookie.
Alice visits www.attacker32.com → Malicious page includes:
  <img src="http://www.seed-server.com?action=addfriend&friend=59">
Browser automatically sends the stored cookie with the request → www.seed-server.com adds Samy as Alice’s friend.
```

### How it is Fixed
Defense mechanisms include:
- **Anti‑CSRF Tokens**: Embed a secret, per‑session token in each HTML form or AJAX request and validate it server‑side. The token is not sent automatically by the browser, so forged requests lack it.
- **SameSite Cookie Attribute**: Set cookies with `SameSite=Strict` or `SameSite=Lax` to prevent them from being sent on cross‑site requests.
- **Referer/Origin Header Checks**: Verify that state‑changing requests originate from the same origin as the application.

By implementing any of these mitigations, the server can distinguish legitimate user‑initiated actions from forged cross‑origin requests.

This lab requires two containers — one for the target site and one for the attacker site — to correctly simulate the cross-origin attack scenario.

---

## Container Architecture

```
HOST MACHINE
  |
  | Hosts file: www.seed-server.com -> 127.0.0.1 (or localhost:10082)
  | Hosts file: www.attacker32.com  -> 127.0.0.1 (or localhost:10083)
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
.\start.ps1       # Windows PowerShell
./start.sh        # Linux / WSL2 bash
```

### Verify Container Status

```bash
docker compose ps
docker inspect elgg-10.9.0.5-csrf
docker inspect attacker-10.9.0.105
```

---

## Layer 2 — Linux Commands (inside the container)

### Open Bash Shell

```bash
docker exec -it elgg-10.9.0.5-csrf bash
```

### Inspect Application Configuration

```bash
cd /var/www/html
grep -n "action" index.php
```

### Exit Container

```bash
exit
```

---

## Layer 3 — Security Tasks

### Access Applications

```
Target Site:   http://localhost:10082  OR  http://www.seed-server.com:10082
Attacker Site: http://localhost:10083  OR  http://www.attacker32.com:10083
```

---

## Stop and Reset

```bash
docker compose down
docker compose down -v
```
