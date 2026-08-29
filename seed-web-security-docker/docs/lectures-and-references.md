# Lecture and Reading References

This file lists the official lecture materials, textbook chapters, and lab manuals
that correspond to each lab in this repository. All documentation in this project
is written based on these sources.

---

## Source: SEED Labs 2.0 — Wenliang (Kevin) Du, Syracuse University

The SEED Labs are developed by Prof. Wenliang Du at Syracuse University.
The companion textbook is: *Computer & Internet Security: A Hands-on Approach* (2nd ed.)

Textbook companion site: https://www.handsonsecurity.net
SEED Labs site: https://seedsecuritylabs.org
Lecture videos: https://www.handsonsecurity.net/video.html

---

## Lab 01 — SQL Injection Attack

| Resource | Link |
|----------|------|
| Lab Manual (official PDF) | https://seedsecuritylabs.org/Labs_20.04/Web/Web_SQL_Injection/ |
| GitHub lab source | https://github.com/seed-labs/seed-labs/tree/master/category-web/Web_SQL_Injection |
| Textbook chapter | Chapter 12 — SQL Injection Attack (*Computer & Internet Security*) |
| OWASP SQLi | https://owasp.org/www-community/attacks/SQL_Injection |
| CWE-89 | https://cwe.mitre.org/data/definitions/89.html |

Key topics covered in the lab manual:
- How web applications construct SQL queries dynamically
- Why string concatenation of user input into queries is dangerous
- SELECT-based injection to bypass authentication
- UPDATE-based injection to modify other users' records
- Countermeasure: prepared statements with parameterized queries

---

## Lab 02 — Cross-Site Scripting (XSS) Attack

| Resource | Link |
|----------|------|
| Lab Manual (official) | https://seedsecuritylabs.org/Labs_20.04/Web/Web_XSS_Elgg/ |
| GitHub lab source | https://github.com/seed-labs/seed-labs/tree/master/category-web/Web_XSS_Elgg |
| Textbook chapter | Chapter 11 — Cross-Site Scripting Attack (*Computer & Internet Security*) |
| OWASP XSS | https://owasp.org/www-community/attacks/xss/ |
| CWE-79 | https://cwe.mitre.org/data/definitions/79.html |

Key topics from the lab manual:
- Stored XSS vs. reflected XSS
- How the browser executes injected scripts within the victim's origin context
- Self-propagating XSS worms (DOM-based and link-based approaches)
- Countermeasure: output encoding (htmlspecialchars), Content Security Policy (CSP)

---

## Lab 03 — Cross-Site Request Forgery (CSRF) Attack

| Resource | Link |
|----------|------|
| Lab Manual (official) | https://seedsecuritylabs.org/Labs_20.04/Web/Web_CSRF_Elgg/ |
| GitHub lab source | https://github.com/seed-labs/seed-labs/tree/master/category-web/Web_CSRF_Elgg |
| Textbook chapter | Chapter 10 — Cross-Site Request Forgery (*Computer & Internet Security*) |
| OWASP CSRF | https://owasp.org/www-community/attacks/csrf |
| CWE-352 | https://cwe.mitre.org/data/definitions/352.html |
| RFC 6265 (Cookies) | https://www.rfc-editor.org/rfc/rfc6265 |

Key topics from the lab manual:
- How browsers automatically attach session cookies to cross-origin requests
- Forging GET and POST requests from a malicious third-party site
- Why the server cannot distinguish a legitimate user request from a forged one
- Countermeasure: synchronizer CSRF tokens, SameSite cookie attribute

---

## Lab 04 — Clickjacking Attack

| Resource | Link |
|----------|------|
| Lab Manual (official) | https://seedsecuritylabs.org/Labs_20.04/Web/Web_Clickjacking/ |
| GitHub lab source | https://github.com/seed-labs/seed-labs/tree/master/category-web/Web_Clickjacking |
| Textbook chapter | Chapter 13 — Clickjacking Attack (*Computer & Internet Security*) |
| OWASP Clickjacking | https://owasp.org/www-community/attacks/Clickjacking |
| CWE-1021 | https://cwe.mitre.org/data/definitions/1021.html |

Key topics from the lab manual:
- UI redress attacks using transparent iframe overlays
- CSS opacity and z-index manipulation to hide the real target
- Position alignment to make victim clicks register on the hidden frame
- Countermeasure: X-Frame-Options header, CSP frame-ancestors directive

---

## Lab 05 — Shellshock Vulnerability

| Resource | Link |
|----------|------|
| Lab Manual (official) | https://seedsecuritylabs.org/Labs_20.04/Web/Shellshock/ |
| GitHub lab source | https://github.com/seed-labs/seed-labs/tree/master/category-web/Shellshock |
| Textbook chapter | Chapter 3 — Shellshock Attack (*Computer & Internet Security*, Software Security section) |
| NVD CVE-2014-6271 | https://nvd.nist.gov/vuln/detail/CVE-2014-6271 |
| NVD CVE-2014-7169 | https://nvd.nist.gov/vuln/detail/CVE-2014-7169 |

Key topics from the lab manual:
- Bash function export mechanism and the parsing bug introduced before patch
- How CGI scripts expose HTTP headers as environment variables to bash
- Exploiting the User-Agent, Referer, and Cookie headers as attack vectors
- Obtaining a reverse shell through a Shellshock payload
- Countermeasure: patching bash, disabling CGI, input sanitization at the server boundary

---

## Background Reading: Web Fundamentals

These concepts underpin all five labs. The SEED lab manuals include dedicated
background sections covering each of these topics.

| Topic | Reference |
|-------|-----------|
| HTTP request/response model | RFC 7230: https://www.rfc-editor.org/rfc/rfc7230 |
| Cookie specification | RFC 6265: https://www.rfc-editor.org/rfc/rfc6265 |
| Same-Origin Policy (SOP) | MDN: https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy |
| Content Security Policy (CSP) | MDN: https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP |
| OWASP Top 10 (2021) | https://owasp.org/www-project-top-ten/ |
| Docker documentation | https://docs.docker.com/ |

---

## Note on Slide Access

Prof. Du's lecture slides for the textbook chapters are distributed to adopting
institutions through the author's website at https://www.handsonsecurity.net/resources.html.
The slides require instructor registration. The lab manuals linked above are the
publicly available equivalent and contain the same theoretical background sections
used to write the documentation in this repository.

If you have access to the textbook slides, the relevant slide decks are:
- Slides-WebSecurity-Basics.pdf
- Slides-CSRF.pdf
- Slides-XSS.pdf
- Slides-SQLInjection.pdf
- Slides-Clickjacking.pdf
- Slides-Shellshock.pdf (in the Software Security section)
