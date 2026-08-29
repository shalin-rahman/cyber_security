# Lab 02 — Cross-Site Scripting (XSS) Attack Lab

Official Reference: https://seedsecuritylabs.org/Labs_20.04/Web/Web_XSS_Elgg/  
Textbook Reference: Chapter 11 — Cross-Site Scripting Attack (*Computer & Internet Security*, Prof. Wenliang Du)

For authorized educational use only.

---

## 01. Security Concept

Cross-Site Scripting (XSS) vulnerabilities occur when a web application incorporates unsanitized user-supplied data into its HTTP response output. When a victim's web browser renders the returned HTML, it interprets and executes any embedded JavaScript payload within the context of the vulnerable site's origin (`www.seed-server.com`). This grants the injected script full access to the victim's session cookies, DOM tree, and ambient authority credentials.

In stored XSS attacks (the focus of this lab), the attacker posts a payload into a persistent database field (e.g., Elgg profile "About Me"). Every user who subsequently views that profile unknowingly executes the payload.

---

## 02. Environment Architecture

```
+-------------------------------------------------------------------------+
|                              HOST MACHINE                               |
|                                                                         |
|  Host Browser: http://www.seed-server.com  (via /etc/hosts -> 10.9.0.5) |
|  Mapped Host Port: 10081 -> Container Port 80                           |
|                                                                         |
|  +-------------------------------------------------------------------+  |
|  |                          DOCKER ENGINE                            |  |
|  |                                                                   |  |
|  |  Docker Bridge Network: net-10.9.0.0-xss (Subnet: 10.9.0.0/24)   |  |
|  |                                                                   |  |
|  |  +---------------------------+     +---------------------------+  |  |
|  |  | Web Container             |     | Database Container        |  |  |
|  |  | elgg-10.9.0.5             |     | mysql-10.9.0.6-xss        |  |  |
|  |  | (10.9.0.5)                |     | (10.9.0.6)                |  |  |
|  |  |                           |     |                           |  |  |
|  |  | +-----------------------+ |     | +-----------------------+ |  |  |
|  |  | | Linux User Space      | |     | | Linux User Space      | |  |  |
|  |  | | Apache 2.4 + PHP 7.x  | |     | | MySQL 8.x Daemon      | |  |  |
|  |  | | Elgg Application Code | |     | | Elgg Database Tables  | |  |  |
|  |  | +-----------------------+ |     | +-----------------------+ |  |  |
|  |  +---------------------------+     +---------------------------+  |  |
|  +-------------------------------------------------------------------+  |
+-------------------------------------------------------------------------+
```

---

## 03. Docker Architecture

| Docker Concept | Lab Implementation | Description |
|----------------|--------------------|-------------|
| **Base Image** | `handsonsecurity/seed-image-www-xss-elgg` | Pre-built image containing Ubuntu user space, Apache, PHP, and vulnerable Elgg |
| **Database Image** | `handsonsecurity/seed-image-mysql-xss-elgg` | MySQL image pre-populated with Elgg database tables and user accounts |
| **Container** | `elgg-10.9.0.5` | Active container instance serving Elgg social network on port 80 |
| **Database Container** | `mysql-10.9.0.6-xss` | Internal MySQL container providing persistent user and profile data |
| **Bridge Network** | `net-10.9.0.0-xss` | Isolated Docker network (`10.9.0.0/24`) isolating XSS lab traffic |
| **Port Binding** | `10081:80` | Forwards host port 10081 to container Apache port 80 |
| **Compose Service** | `docker-compose.yml` | Multi-container orchestration declaring dependencies and IP static addresses |

---

## 04. Linux Learning Inside Elgg Container (`elgg-10.9.0.5`)

To enter the Elgg container shell:
```bash
docker exec -it elgg-10.9.0.5 bash
```

### Linux Inspection Commands inside Elgg Container

1. **`pwd`**
   - *What*: Prints working directory (`/var/www/html`).
   - *Why*: Confirms position at the root of Elgg's web application deployment directory.
   - *Lab Application*: Verify active directory before inspecting PHP source files.

2. **`ls -la`**
   - *What*: Displays detailed file permissions, ownership, and directory listings.
   - *Why*: Identifies web assets, configuration files (`elgg-config.php`), and permission models.
   - *Lab Application*: Verify that `/var/www/html` files are owned by `www-data`.

3. **`whoami`**
   - *What*: Returns active user identity (`root`).
   - *Why*: Confirms that `docker exec` enters as root, granting admin inspection capabilities.
   - *Lab Application*: Understand that container administrative tasks run as root while web processes run as `www-data`.

4. **`id`**
   - *What*: Displays UID (`0`), GID (`0`), and group associations.
   - *Why*: Demonstrates user privilege boundaries inside container user space.
   - *Lab Application*: Compare interactive root shell (`uid=0`) with web process execution (`uid=33(www-data)`).

5. **`hostname`**
   - *What*: Displays container network hostname (`elgg-10.9.0.5`).
   - *Why*: Verifies container identification on the Docker bridge network.
   - *Lab Application*: Confirms node identity on `net-10.9.0.0-xss`.

6. **`ip addr`**
   - *What*: Lists network interfaces and assigned IP address (`10.9.0.5/24`).
   - *Why*: Confirms static IP configuration on interface `eth0`.
   - *Lab Application*: Verify container networking matches SEED architecture specifications.

7. **`ps aux`**
   - *What*: Displays running process table.
   - *Why*: Reveals PID hierarchy and active service daemons.
   - *Lab Application*: Observe master Apache process running as `root` (PID 1) and worker processes running as `www-data`.

8. **`env`**
   - *What*: Displays exported environment variables.
   - *Why*: Shows settings passed from `docker-compose.yml`.
   - *Lab Application*: Inspect `MYSQL_HOST=10.9.0.6` used by PHP database connection logic.

---

## 05. Linux Learning Inside MySQL Container (`mysql-10.9.0.6-xss`)

To enter the MySQL container shell:
```bash
docker exec -it mysql-10.9.0.6-xss bash
```

### Linux Inspection Commands inside MySQL Container

1. **`ps aux`**
   - *What*: Displays process list inside database container.
   - *Why*: Confirms MySQL daemon process (`mysqld`) execution.
   - *Lab Application*: Observe `mysqld` running under dedicated unprivileged `mysql` user account.

2. **`hostname` and `ip addr`**
   - *What*: Returns container network identity (`mysql-10.9.0.6`).
   - *Why*: Confirms database container is attached to bridge network at IP `10.9.0.6`.
   - *Lab Application*: Verify IP address matches `MYSQL_HOST` declared in web container environment.

3. **`env`**
   - *What*: Shows environment variables inside database container.
   - *Why*: Verifies `MYSQL_ROOT_PASSWORD=seedubuntu` configuration.
   - *Lab Application*: Inspect root credentials used for database management.

*Note: Database containers omit web utilities like Apache or PHP binaries, illustrating container minimal user-space design.*

---

## 06. Docker Networking

Containers communicate across custom bridge network `net-10.9.0.0-xss` on subnet `10.9.0.0/24`. Embedded Docker DNS resolves container names to IP addresses. Host port forwarding (`10081:80`) maps host network traffic to the web container's internal port 80.

---

## 07. Browser to Container Communication

1. User enters `http://www.seed-server.com` in host browser.
2. Host `/etc/hosts` resolves domain to `10.9.0.5` (or host IP with port `10081`).
3. Browser transmits HTTP request to port 10081.
4. Docker Engine forwards packet to `elgg-10.9.0.5` port 80.
5. Apache receives HTTP request, passes execution to PHP engine, fetches stored profile data from MySQL (`10.9.0.6`), and returns HTML response to browser.

---

## 08. Application Architecture

Elgg is an open-source PHP social networking engine backed by MySQL.
- **Pre-seeded Accounts**:
  - `admin` / `seedelgg` (Administrator)
  - `alice` / `seedalice` (Victim user)
  - `boby` / `seedboby` (Regular user)
  - `charlie` / `seedcharlie` (Regular user)
  - `samy` / `seedsamy` (Attacker user)

---

## 09. XSS Data Flow

```
1. Attacker (Samy) logs in and edits profile "About Me" field.
   Payload: <script>alert(document.cookie);</script>
      |
      v
2. PHP Application accepts input without escaping.
   MySQL Database stores raw unescaped string in elgg_users_entity table.
      |
      v
3. Victim (Alice) logs in and visits Samy's profile page.
      |
      v
4. Server retrieves string from MySQL and embeds it in HTML HTTP response.
      |
      v
5. Victim Browser parses HTML, encounters <script> tag, and executes JavaScript.
      |
      v
6. Payload executes inside www.seed-server.com origin, granting access to Alice's document.cookie.
```

---

## 10. Official Lab Tasks

Download official PDF handout: https://seedsecuritylabs.org/Labs_20.04/Web/Web_XSS_Elgg/

- **Task 1**: Post a malicious message to display an alert window.
- **Task 2**: Display the victim's session cookies in an alert box.
- **Task 3**: Steal the victim's session cookies by transmitting them to an attacker netcat listener.
- **Task 4**: Write an XSS payload that automatically adds Samy as a friend when viewed.
- **Task 5**: Write an XSS payload that automatically modifies the victim's profile data.
- **Task 6**: Construct a self-propagating XSS worm (DOM approach or link approach).
- **Task 7**: Defeat XSS attacks using Content Security Policy (CSP) headers.

---

## 11. Container Debugging

```bash
# Level 1: Check container execution status
docker compose ps

# Level 2: Verify network bridge status
docker network inspect net-10.9.0.0-xss

# Level 3: Verify MySQL database accessibility
docker exec -it mysql-10.9.0.6-xss mysql -u root -pseedubuntu -e "SHOW DATABASES;"
```

---

## 12. Linux Log Inspection

Inside Elgg container (`elgg-10.9.0.5`):
```bash
# Stream Apache access log
tail -f /var/log/apache2/access.log

# Inspect Apache error log
cat /var/log/apache2/error.log
```

---

## 13. Docker Log Inspection

From host terminal inside `labs/02-xss`:
```bash
# Stream combined container logs
docker compose logs -f

# Stream Elgg web container logs only
docker compose logs -f elgg
```

---

## 14. Root Cause

The application outputs user-controlled variables directly into HTML without context-aware HTML entity encoding:
```php
// Unsafe PHP output
echo $user_profile->description;
```

---

## 15. Countermeasures

### 1. HTML Output Encoding
Convert special HTML characters to HTML entities before rendering:
```php
// Safe PHP output
echo htmlspecialchars($user_profile->description, ENT_QUOTES, 'UTF-8');
```

### 2. Content Security Policy (CSP)
Configure HTTP response headers to disable inline script execution:
```http
Content-Security-Policy: script-src 'self'; object-src 'none';
```

---

## 16. Cleanup and Reset

```bash
# Stop containers
docker compose down

# Reset lab database state to clean initial state
docker compose down -v
docker compose up -d
```

---

## 17. Learning Summary

Through this lab, students learn:
1. **Linux**: Container shell navigation, user privileges (`root` vs `www-data`), process tables, and Apache log tracking.
2. **Docker**: Multi-container Compose orchestration, bridge networks, port bindings, and volume reset mechanics.
3. **Networking**: Host resolution (`/etc/hosts`), bridge IP routing (`10.9.0.5`), and HTTP message inspection.
4. **Web Security**: Stored XSS mechanics, cookie scoping, self-propagating worms, output encoding, and CSP enforcement.
