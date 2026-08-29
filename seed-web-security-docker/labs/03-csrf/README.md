# Lab 03 — Cross-Site Request Forgery (CSRF) Attack Lab

Official Reference: https://seedsecuritylabs.org/Labs_20.04/Web/Web_CSRF_Elgg/  
Textbook Reference: Chapter 10 — Cross-Site Request Forgery (*Computer & Internet Security*, Prof. Wenliang Du)

For authorized educational use only.

---

## 1. Security Concept

Cross-Site Request Forgery (CSRF) tricks an authenticated victim's web browser into issuing unauthorized HTTP requests to a target web application. Because browsers automatically include ambient authentication credentials (session cookies) with cross-origin requests, the target application accepts and executes the request without verifying user intent.

---

## 2. Standard 14-Step Learning Sequence

```
STEP 1  Understand Security Concept  (Automatic cookie attachment on cross-origin requests)
STEP 2  Understand Lab Architecture (Victim Browser -> Legitimate Site & Attacker Site)
STEP 3  Understand Docker Architecture (elgg-10.9.0.5-csrf + attacker-10.9.0.105 + mysql)
STEP 4  Start Containers            (docker compose up -d)
STEP 5  Inspect Docker               (docker compose ps, status.sh)
STEP 6  Enter Linux Containers       (docker exec -it elgg-10.9.0.5-csrf bash)
STEP 7  Inspect Linux Environment    (pwd, ls -la, ps aux, whoami, id, hostname, ip addr, env)
STEP 8  Inspect Application          (Examine attacker HTML page & Elgg action endpoints)
STEP 9  Complete Official Lab Tasks  (Forge GET/POST requests from attacker site)
STEP 10 Inspect Logs                 (docker compose logs -f attacker)
STEP 11 Understand Root Cause        (Missing session token / unrestricted cookie scoping)
STEP 12 Implement Countermeasure     (Enable CSRF tokens & test SameSite cookies)
STEP 13 Stop and Reset               (docker compose down -v)
STEP 14 Document Learning            (Record request headers and defense verification)
```

---

## 3. Environment & Architecture Diagrams

### Multi-Layer Container Architecture

```
+-------------------------------------------------------------------------+
|                              HOST MACHINE                               |
|                                                                         |
|  Host Browser Tabs:                                                     |
|  - Victim Tab:   http://www.seed-server.com  (via /etc/hosts -> 10.9.0.5) |
|  - Attacker Tab: http://www.attacker32.com   (via /etc/hosts -> 10.9.0.105)|
|                                                                         |
|  +-------------------------------------------------------------------+  |
|  |                          DOCKER ENGINE                            |  |
|  |                                                                   |  |
|  |  Docker Bridge Network: net-10.9.0.0-csrf (Subnet: 10.9.0.0/24)  |  |
|  |                                                                   |  |
|  |  +---------------------+ +--------------------+ +---------------+  |  |
|  |  | Elgg Container      | | Attacker Container | | MySQL DB      |  |  |
|  |  | elgg-10.9.0.5-csrf  | | attacker-10.9.0.105| | mysql-10.9.0.6|  |  |
|  |  | (10.9.0.5:10082)    | | (10.9.0.105:10083) | | (10.9.0.6)    |  |  |
|  |  +---------------------+ +--------------------+ +---------------+  |  |
|  +-------------------------------------------------------------------+  |
+-------------------------------------------------------------------------+
```

### Security Data-Flow Diagram

```
1. Victim (Alice) logs into www.seed-server.com
   Browser stores session cookie for www.seed-server.com
      |
      v
2. Alice visits www.attacker32.com (holding active Elgg session)
      |
      v
3. Attacker page triggers request to www.seed-server.com:
   GET Vector:  <img src="http://www.seed-server.com/action/friends/add?friend=59">
   POST Vector: Auto-submitting hidden HTML form
      |
      v
4. Browser automatically attaches Alice's session cookie for www.seed-server.com
      |
      v
5. Elgg validates session cookie & adds Samy as friend WITHOUT Alice's consent
```

---

## 4. Docker Learning Matrix

| Docker Concept | Lab Specific Implementation | Function |
|----------------|-----------------------------|----------|
| **Base Image (Elgg)** | `handsonsecurity/seed-image-www-csrf-elgg` | Runs legitimate Elgg social network |
| **Base Image (Attacker)** | `handsonsecurity/seed-image-www-csrf-attacker` | Runs Apache server hosting malicious CSRF pages |
| **Database Image** | `handsonsecurity/seed-image-mysql-csrf` | MySQL database pre-populated with Elgg records |
| **Containers** | `elgg-10.9.0.5-csrf` / `attacker-10.9.0.105` | Active application and attacker containers |
| **Bridge Network** | `net-10.9.0.0-csrf` | Subnet `10.9.0.0/24` connecting all lab containers |
| **Port Bindings** | `10082:80` (Elgg) / `10083:80` (Attacker) | Maps host access ports to container Apache instances |

---

## 5. Linux Learning Inside the Containers

To enter the Elgg container shell:
```bash
docker exec -it elgg-10.9.0.5-csrf bash
```

To enter the Attacker container shell:
```bash
docker exec -it attacker-10.9.0.105 bash
```

### Linux Inspection Commands

1. **`pwd`**
   - *What*: Displays current directory (`/var/www/html`).
   - *Why*: Identifies active working location inside container.
   - *Lab Application*: Verify position before creating malicious HTML pages on attacker container.

2. **`ls -la`**
   - *What*: Lists files and permissions in long format.
   - *Why*: Inspects website file structure.
   - *Lab Application*: Check permissions on `/var/www/html/index.html` inside attacker container.

3. **`whoami` and `id`**
   - *What*: Returns active user identity (`root`).
   - *Why*: Confirms root administrative shell access via `docker exec`.
   - *Lab Application*: Contrast root shell with `www-data` process execution.

4. **`hostname` and `ip addr`**
   - *What*: Displays container hostname and IP address (`10.9.0.5` or `10.9.0.105`).
   - *Why*: Verifies container IP assignment on `net-10.9.0.0-csrf`.
   - *Lab Application*: Confirm container addresses match `/etc/hosts` mappings.

5. **`ps aux`**
   - *What*: Displays running process list.
   - *Why*: Inspects master and worker Apache processes.
   - *Lab Application*: Verify Apache service status.

6. **`env` and `printenv`**
   - *What*: Displays environment variables.
   - *Why*: Inspects container environment settings.
   - *Lab Application*: Verify database host settings inside Elgg container.

---

## 6. Official Lab Tasks

Download official PDF handout: https://seedsecuritylabs.org/Labs_20.04/Web/Web_CSRF_Elgg/

- **Task 1**: Observe HTTP request structure using Developer Tools.
- **Task 2**: Perform CSRF attack using GET request (add friend action).
- **Task 3**: Perform CSRF attack using POST request (modify profile action).
- **Task 4**: Enable and test Elgg's built-in CSRF token countermeasure.
- **Task 5**: Experiment with SameSite cookie attributes (`Strict` vs `Lax` vs `None`).

---

## 7. Countermeasures

### 1. Synchronizer Token Pattern
```html
<input type="hidden" name="__elgg_token" value="d3f8a12b59e4">
<input type="hidden" name="__elgg_ts" value="1693000000">
```

### 2. SameSite Cookie Attribute
```http
Set-Cookie: Elgg=sessionid123; SameSite=Strict; Path=/; HttpOnly
```

---

## 8. Stop and Reset

```bash
docker compose down        # Stop containers
docker compose down -v    # Reset database state
```
