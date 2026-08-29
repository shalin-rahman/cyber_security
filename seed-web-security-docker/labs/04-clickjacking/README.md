# Lab 04 — Clickjacking Attack Lab

Official Reference: https://seedsecuritylabs.org/Labs_20.04/Web/Web_Clickjacking/  
Textbook Reference: Chapter 13 — Clickjacking Attack (*Computer & Internet Security*, Prof. Wenliang Du)

For authorized educational use only.

---

## 1. Security Concept

Clickjacking (UI Redress Attack) tricks a user into clicking on a vulnerable target website element while perceiving that they are interacting with an innocent element on an attacker-controlled page. The attacker overlays a transparent `<iframe>` containing the target web page directly over a visible "bait" element.

---

## 2. Standard 14-Step Learning Sequence

```
STEP 1  Understand Security Concept  (UI redress via transparent iframe overlay)
STEP 2  Understand Lab Architecture (Victim Browser -> Attacker Site embedding Target Site)
STEP 3  Understand Docker Architecture (cjlab-10.9.0.80 + cjlab-attacker-10.9.0.81)
STEP 4  Start Containers            (docker compose up -d)
STEP 5  Inspect Docker               (docker compose ps, status.sh)
STEP 6  Enter Linux Containers       (docker exec -it cjlab-10.9.0.80 bash)
STEP 7  Inspect Linux Environment    (pwd, ls -la, ps aux, whoami, id, hostname, ip addr, env)
STEP 8  Inspect Application          (Examine target button structure & attacker CSS overlay)
STEP 9  Complete Official Lab Tasks  (Align bait button over target iframe button)
STEP 10 Inspect Logs                 (docker compose logs -f)
STEP 11 Understand Root Cause        (Missing frame restrictions allows cross-origin framing)
STEP 12 Implement Countermeasure     (Apply X-Frame-Options & CSP frame-ancestors headers)
STEP 13 Stop and Reset               (docker compose down)
STEP 14 Document Learning            (Record CSS offset alignment and defense results)
```

---

## 3. Environment & Architecture Diagrams

### Multi-Layer Container Architecture

```
+-------------------------------------------------------------------------+
|                              HOST MACHINE                               |
|                                                                         |
|  Host Browser Tabs:                                                     |
|  - Target Site:   http://www.cjlab.com          (via hosts -> 10.9.0.80) |
|  - Attacker Site: http://www.cjlab-attacker.com (via hosts -> 10.9.0.81) |
|                                                                         |
|  +-------------------------------------------------------------------+  |
|  |                          DOCKER ENGINE                            |  |
|  |                                                                   |  |
|  |  Docker Bridge Network: net-10.9.0.0-clickjacking (10.9.0.0/24)  |  |
|  |                                                                   |  |
|  |  +---------------------------+     +---------------------------+  |  |
|  |  | Target Web Container      |     | Attacker Web Container    |  |  |
|  |  | cjlab-10.9.0.80           |     | cjlab-attacker-10.9.0.81  |  |  |
|  |  | (10.9.0.80:10084)         |     | (10.9.0.81:10085)         |  |  |
|  |  +---------------------------+     +---------------------------+  |  |
|  +-------------------------------------------------------------------+  |
+-------------------------------------------------------------------------+
```

### Security UI Layering Diagram

```
Top Layer (z-index: 10, opacity: 0.0):
  <iframe src="http://www.cjlab.com">
    [ Hidden Target Button: "Delete Account" ]  <-- Aligned precisely over bait
  </iframe>

Bottom Layer (z-index: 1, opacity: 1.0):
  <button id="bait">
    [ Visible Bait Button: "CLAIM FREE GIFT" ]
  </button>

User clicks "CLAIM FREE GIFT" -> Browser registers click on hidden "Delete Account" button
```

---

## 4. Docker Learning Matrix

| Docker Concept | Lab Specific Implementation | Function |
|----------------|-----------------------------|----------|
| **Base Image (Target)** | `handsonsecurity/seed-image-www-clickjacking` | Runs Apache server hosting legitimate target page |
| **Base Image (Attacker)** | `handsonsecurity/seed-image-www-clickjacking-attacker` | Runs Apache server hosting clickjacking overlay page |
| **Containers** | `cjlab-10.9.0.80` / `cjlab-attacker-10.9.0.81` | Running target and attacker web containers |
| **Bridge Network** | `net-10.9.0.0-clickjacking` | Subnet `10.9.0.0/24` connecting lab containers |
| **Port Bindings** | `10084:80` (Target) / `10085:80` (Attacker) | Forwards host ports 10084 and 10085 to container HTTP ports |

---

## 5. Linux Learning Inside the Containers

To enter the target container shell:
```bash
docker exec -it cjlab-10.9.0.80 bash
```

To enter the attacker container shell:
```bash
docker exec -it cjlab-attacker-10.9.0.81 bash
```

### Linux Inspection Commands

1. **`pwd`**
   - *What*: Displays current directory (`/var/www/html`).
   - *Why*: Confirms position at web server root.
   - *Lab Application*: Verify active directory before inspecting HTML/CSS files.

2. **`ls -la`**
   - *What*: Lists files and permissions in long format.
   - *Why*: Inspects HTML assets and Apache configuration folders.
   - *Lab Application*: Locate target website files inside `/var/www/html`.

3. **`whoami` and `id`**
   - *What*: Returns user identity (`root`).
   - *Why*: Confirms root shell privileges inside container.
   - *Lab Application*: Contrast container administration with `www-data` process execution.

4. **`hostname` and `ip addr`**
   - *What*: Displays container hostname and IP (`10.9.0.80` or `10.9.0.81`).
   - *Why*: Verifies network interface assignment.
   - *Lab Application*: Confirm container addresses match `/etc/hosts` entries.

5. **`ps aux`**
   - *What*: Displays running process list.
   - *Why*: Inspects Apache daemon process hierarchy.
   - *Lab Application*: Verify Apache master and worker processes.

6. **`env` and `printenv`**
   - *What*: Displays environment variables.
   - *Why*: Inspects container environment configuration.
   - *Lab Application*: Verify system execution environment variables.

---

## 6. Official Lab Tasks

Download official PDF handout: https://seedsecuritylabs.org/Labs_20.04/Web/Web_Clickjacking/

- **Task 1**: Inspect and understand the target website page structure.
- **Task 2**: Construct a basic clickjacking attack using iframe transparency (`opacity: 0`).
- **Task 3**: Align bait and target elements using CSS absolute positioning.
- **Task 4**: Apply defense using `X-Frame-Options: DENY` HTTP response header.
- **Task 5**: Apply defense using Content Security Policy `frame-ancestors 'none'` directive.

---

## 7. Vulnerability Root Cause and Countermeasures

### Root Cause
Target website allows unrestricted embedding inside cross-origin `<iframe>` elements.

### Countermeasure 1: X-Frame-Options Header
```http
X-Frame-Options: DENY
```

### Countermeasure 2: Content Security Policy (`frame-ancestors`)
```http
Content-Security-Policy: frame-ancestors 'none';
```

---

## 8. Stop and Reset

```bash
docker compose down        # Stop containers
```
