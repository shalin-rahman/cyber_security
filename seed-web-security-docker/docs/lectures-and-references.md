# Official SEED Labs Lecture Sync & Reference Sitemap

This document maps all five Web Security labs in this repository directly to the official SEED Labs 2.0 curriculum, Prof. Wenliang Du's video lectures, textbook chapters (*Computer & Internet Security: A Hands-on Approach*, 2nd Edition), MITRE CWE classifications, and NIST CVE identifiers.

Official SEED Labs Site: https://seedsecuritylabs.org/labs.html  
Book & Video Companion Site: https://www.handsonsecurity.net/video.html

---

## 1. Global Lecture & Curriculum Mapping

```
+----------------------------------------------------------------------------------------------------------+
|                                     SEED WEB SECURITY CURRICULUM SITEMAP                                 |
+----------------------------------------------------------------------------------------------------------+
|  LAB MODULE           | TEXTBOOK CHAPTER | MITRE CWE / CVE  | CORE LECTURE TOPICS                       |
+-----------------------+------------------+------------------+-------------------------------------------+
| 01 SQL Injection      | Chapter 12       | CWE-89           | SQL Syntax, String Concatenation,         |
|                       |                  |                  | Authentication Bypass, Prepared Stmts     |
+-----------------------+------------------+------------------+-------------------------------------------+
| 02 XSS (Elgg)         | Chapter 11       | CWE-79           | Stored/Reflected XSS, Session Theft,      |
|                       |                  |                  | Samy Worm, Output Encoding (htmlspecialchars)|
+-----------------------+------------------+------------------+-------------------------------------------+
| 03 CSRF (Elgg)        | Chapter 10       | CWE-352          | Cross-Origin Cookie Auto-Attach,          |
|                       |                  |                  | Forged POST requests, Anti-CSRF Tokens    |
+-----------------------+------------------+------------------+-------------------------------------------+
| 04 Clickjacking       | Chapter 13       | CWE-1021         | Transparent Iframe Overlays, UI Redress,  |
|                       |                  |                  | X-Frame-Options Header, CSP frame-ancestors|
+-----------------------+------------------+------------------+-------------------------------------------+
| 05 Shellshock         | Chapter 3        | CVE-2014-6271    | Bash Function Export Bug, Apache CGI      |
|                       |                  | CVE-2014-7169    | Env Var Parsing, Remote Code Execution   |
+----------------------------------------------------------------------------------------------------------+
```

---

## 2. Lab 01 — SQL Injection Attack

### Official References
- **SEED Lab Manual (PDF)**: https://seedsecuritylabs.org/Labs_20.04/Web/Web_SQL_Injection/
- **GitHub Repository**: https://github.com/seed-labs/seed-labs/tree/master/category-web/Web_SQL_Injection
- **Textbook Correlation**: Chapter 12 — *SQL Injection Attack* (Prof. Wenliang Du)
- **Video Lecture**: Web Security Series — SQL Injection Attack & Defense (https://www.handsonsecurity.net/video.html)
- **MITRE Classification**: [CWE-89: Improper Neutralization of Special Elements used in an SQL Command](https://cwe.mitre.org/data/definitions/89.html)
- **OWASP Reference**: [OWASP Top 10 — Injection](https://owasp.org/www-community/attacks/SQL_Injection)

### Synchronized Lecture Topics
1. **Relational Database Query Construction**:
   How web applications construct SQL queries dynamically using input parameters.
2. **Vulnerability Mechanics**:
   Unsafe string concatenation where input string boundary characters (`'`, `"`) alter query parse trees.
3. **Attack Vectors**:
   - Authentication Bypass: Injecting comment characters (`#`, `--`) to strip password clauses.
   - Data Exfiltration: Injecting `UNION SELECT` to retrieve data from unrelated tables.
   - Data Modification: Injecting stacked or inline `UPDATE` queries.
4. **Defensive Countermeasures**:
   - Prepared Statements (Parameterized Queries): Pre-compiling SQL query templates in MySQL and binding parameters as strict data values.
   - Object-Relational Mapping (ORM) and Least-Privilege Database User Accounts.

---

## 3. Lab 02 — Cross-Site Scripting (XSS)

### Official References
- **SEED Lab Manual (PDF)**: https://seedsecuritylabs.org/Labs_20.04/Web/Web_XSS_Elgg/
- **GitHub Repository**: https://github.com/seed-labs/seed-labs/tree/master/category-web/Web_XSS_Elgg
- **Textbook Correlation**: Chapter 11 — *Cross-Site Scripting Attack* (Prof. Wenliang Du)
- **Video Lecture**: Web Security Series — Cross-Site Scripting (XSS) Mechanics (https://www.handsonsecurity.net/video.html)
- **MITRE Classification**: [CWE-79: Improper Neutralization of Input During Web Page Generation](https://cwe.mitre.org/data/definitions/79.html)
- **OWASP Reference**: [OWASP Top 10 — Cross-Site Scripting (XSS)](https://owasp.org/www-community/attacks/xss/)

### Synchronized Lecture Topics
1. **Browser Script Execution Model**:
   How browsers parse HTML markup and execute JavaScript embedded inside `<script>` tags, event handlers, or inline attributes.
2. **Vulnerability Types**:
   - Stored (Persistent) XSS: Malicious payload stored permanently inside application databases (e.g., Elgg user profiles) and rendered to victim browsers.
   - Reflected XSS: Non-persistent payloads reflected via HTTP GET request parameters.
3. **Attack Scenarios**:
   - Session Hijacking: Reading `document.cookie` and exfiltrating session tokens via HTTP requests to attacker servers.
   - Self-Propagating Worms: Crafting AJAX payloads that replicate the XSS script into visiting victim user profiles (the Samy Worm pattern).
4. **Defensive Countermeasures**:
   - Context-Aware Output Encoding: Converting dangerous HTML characters (`<`, `>`, `"`, `'`, `&`) using `htmlspecialchars()`.
   - Content Security Policy (CSP) headers restricting script execution sources.
   - `HttpOnly` cookie flags preventing JavaScript access to session identifiers.

---

## 4. Lab 03 — Cross-Site Request Forgery (CSRF)

### Official References
- **SEED Lab Manual (PDF)**: https://seedsecuritylabs.org/Labs_20.04/Web/Web_CSRF_Elgg/
- **GitHub Repository**: https://github.com/seed-labs/seed-labs/tree/master/category-web/Web_CSRF_Elgg
- **Textbook Correlation**: Chapter 10 — *Cross-Site Request Forgery* (Prof. Wenliang Du)
- **Video Lecture**: Web Security Series — CSRF Vulnerabilities & Token Defenses (https://www.handsonsecurity.net/video.html)
- **MITRE Classification**: [CWE-352: Cross-Site Request Forgery (CSRF)](https://cwe.mitre.org/data/definitions/352.html)
- **OWASP Reference**: [OWASP Top 10 — Cross-Site Request Forgery](https://owasp.org/www-community/attacks/csrf)

### Synchronized Lecture Topics
1. **Browser Cookie Credential Handling**:
   The Same-Origin Policy (SOP) allows cross-origin requests (`<img>`, `<form>`, `<iframe>`), but browsers automatically append stored domain cookies to all outgoing HTTP requests.
2. **Vulnerability Mechanics**:
   An attacker site tricks an authenticated victim browser into forging state-changing HTTP GET or POST requests against a target application.
3. **Attack Vectors**:
   - GET-based CSRF: Hidden `<img>` tags triggering background GET requests.
   - POST-based CSRF: Auto-submitting hidden HTML forms (`document.forms[0].submit()`).
4. **Defensive Countermeasures**:
   - Anti-CSRF Tokens: Generating cryptographically secure, unpredictable session-bound tokens (`$_SESSION['csrf_token']`) verified on state-changing requests.
   - `SameSite` Cookie Attribute (`Strict` / `Lax`).

---

## 5. Lab 04 — Clickjacking (UI Redress)

### Official References
- **SEED Lab Manual (PDF)**: https://seedsecuritylabs.org/Labs_20.04/Web/Web_Clickjacking/
- **GitHub Repository**: https://github.com/seed-labs/seed-labs/tree/master/category-web/Web_Clickjacking
- **Textbook Correlation**: Chapter 13 — *Clickjacking Attack* (Prof. Wenliang Du)
- **Video Lecture**: Web Security Series — UI Redress & Frame Security (https://www.handsonsecurity.net/video.html)
- **MITRE Classification**: [CWE-1021: Improper Restriction of Rendered UI Layers or Frames](https://cwe.mitre.org/data/definitions/1021.html)
- **OWASP Reference**: [OWASP Top 10 — Clickjacking](https://owasp.org/www-community/attacks/Clickjacking)

### Synchronized Lecture Topics
1. **UI Layering & Browser Rendering**:
   CSS positioning (`position: absolute`, `z-index`) and transparency (`opacity: 0.0`) allow multiple document layers to overlap on the screen.
2. **Vulnerability Mechanics**:
   An attacker embeds the target website inside an invisible `<iframe>` positioned directly over an enticing decoy page (e.g., "Win a Prize"). The user's physical mouse clicks land on the hidden target site's action buttons.
3. **Defensive Countermeasures**:
   - HTTP Response Header: `X-Frame-Options: DENY` or `SAMEORIGIN`.
   - Content Security Policy (CSP): `Content-Security-Policy: frame-ancestors 'none'`.

---

## 6. Lab 05 — Shellshock Vulnerability

### Official References
- **SEED Lab Manual (PDF)**: https://seedsecuritylabs.org/Labs_20.04/Web/Shellshock/
- **GitHub Repository**: https://github.com/seed-labs/seed-labs/tree/master/category-web/Shellshock
- **Textbook Correlation**: Chapter 3 — *Shellshock Attack* (Prof. Wenliang Du)
- **Video Lecture**: System & Web Security — The Shellshock Vulnerability (https://www.handsonsecurity.net/video.html)
- **NIST CVE Database**: [CVE-2014-6271](https://nvd.nist.gov/vuln/detail/CVE-2014-6271), [CVE-2014-7169](https://nvd.nist.gov/vuln/detail/CVE-2014-7169)

### Synchronized Lecture Topics
1. **Environment Variable Function Export Bug**:
   GNU Bash (versions through 4.3) parses function definitions stored in environment variables (e.g., `VAR='() { :; }; command'`) and executes trailing commands immediately upon shell invocation.
2. **CGI Environment Variable Injection**:
   When Apache receives HTTP requests for CGI scripts, it maps incoming HTTP headers (`User-Agent`, `Referer`, `Cookie`) into environment variables (`HTTP_USER_AGENT`, `HTTP_REFERER`).
3. **Attack Vectors**:
   Injecting function payloads into HTTP headers using `curl.exe -A "() { :; }; <command>"` to achieve Remote Code Execution (RCE) and spawn reverse shells.
4. **Defensive Countermeasures**:
   - Patching GNU Bash binary to separate environment variable definitions from function parsing logic.
   - Replacing legacy CGI scripts with modern web server application runtimes.
