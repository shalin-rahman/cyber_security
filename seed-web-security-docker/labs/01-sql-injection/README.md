# Lab 01 — SQL Injection Attack Lab

Official Reference: https://seedsecuritylabs.org/Labs_20.04/Web/Web_SQL_Injection/  
Textbook Reference: Chapter 12 — SQL Injection Attack (*Computer & Internet Security*, Prof. Wenliang Du)

For authorized educational use only.

---

## 1. Security Concept

SQL injection occurs when an application builds SQL queries using unsanitized user string concatenation. An attacker supplying crafted SQL syntax alters query logic, enabling authentication bypass, unauthorized data exfiltration, or database modifications.

---

## 2. Standard 14-Step Learning Sequence

```
STEP 1  Understand Security Concept  (Unsafe string concatenation -> altered SQL logic)
STEP 2  Understand Lab Architecture (Browser -> Apache/PHP -> MySQL Database)
STEP 3  Understand Docker Architecture (www-10.9.0.5 + mysql-10.9.0.6 on net-10.9.0.0-sqli)
STEP 4  Start Containers            (docker compose up -d)
STEP 5  Inspect Docker               (docker compose ps, status.sh)
STEP 6  Enter Linux Containers       (docker exec -it www-10.9.0.5 bash)
STEP 7  Inspect Linux Environment    (pwd, ls -la, ps aux, whoami, id, hostname, ip addr, env)
STEP 8  Inspect Application          (Examine /var/www/html/ index and search PHP code)
STEP 9  Complete Official Lab Tasks  (Perform SELECT/UPDATE injection attacks in browser)
STEP 10 Inspect Logs                 (docker compose logs -f, tail -f /var/log/apache2/access.log)
STEP 11 Understand Root Cause        (Review unsafe $sql string concatenation)
STEP 12 Implement Countermeasure     (Rewrite PHP code using prepared statements)
STEP 13 Stop and Reset               (docker compose down -v)
STEP 14 Document Learning            (Record payload behavior and defense notes)
```

---

## 3. Environment & Architecture Diagrams

### Multi-Layer Container Architecture

```
+-------------------------------------------------------------------------+
|                              HOST MACHINE                               |
|                                                                         |
|  Host Browser: http://www.seed-server.com  (via /etc/hosts -> 10.9.0.5) |
|  Mapped Host Port: 10080 -> Container Port 80                           |
|                                                                         |
|  +-------------------------------------------------------------------+  |
|  |                          DOCKER ENGINE                            |  |
|  |                                                                   |  |
|  |  Docker Bridge Network: net-10.9.0.0-sqli (Subnet: 10.9.0.0/24)  |  |
|  |                                                                   |  |
|  |  +---------------------------+     +---------------------------+  |  |
|  |  | Web Container             |     | Database Container        |  |  |
|  |  | www-10.9.0.5              |     | mysql-10.9.0.6            |  |  |
|  |  | (10.9.0.5)                |     | (10.9.0.6)                |  |  |
|  |  |                           |     |                           |  |  |
|  |  | +-----------------------+ |     | +-----------------------+ |  |  |
|  |  | | Linux User Space      | |     | | Linux User Space      | |  |  |
|  |  | | Apache 2.4 + PHP      | |     | | MySQL 8.x Daemon      | |  |  |
|  |  | | Unsafe Search App     | |     | | sqllab_users Database | |  |  |
|  |  | +-----------------------+ |     | +-----------------------+ |  |  |
|  |  +---------------------------+     +---------------------------+  |  |
|  +-------------------------------------------------------------------+  |
+-------------------------------------------------------------------------+
```

### Security Data-Flow Diagram

```
Attacker Form Input: admin'#
      |
      v
PHP Application String Concatenation:
"SELECT * FROM credential WHERE name='admin'#' AND Password='$pwd'"
      |
      v
MySQL Parser evaluates query:
Evaluates SELECT * FROM credential WHERE name='admin'
Ignores everything after # (treated as SQL comment)
      |
      v
MySQL returns Admin record -> Authentication Bypass Successful
```

---

## 4. Docker Learning Matrix

| Docker Concept | Lab Specific Implementation | Function |
|----------------|-----------------------------|----------|
| **Base Image** | `handsonsecurity/seed-image-www-sqli` | Provides Apache/PHP runtime and vulnerable application |
| **Database Image** | `handsonsecurity/seed-image-mysql-sqli` | Pre-populated MySQL image containing `sqllab_users` DB |
| **Containers** | `www-10.9.0.5` / `mysql-10.9.0.6` | Running web and database containers |
| **Bridge Network** | `net-10.9.0.0-sqli` | Isolated bridge network (`10.9.0.0/24`) |
| **Port Binding** | `10080:80` | Host port 10080 forwards to container Apache port 80 |
| **Volume** | `mysql-data` | Preserves database state across restarts |

---

## 5. Linux Learning Inside the Containers

To enter the web container shell:
```bash
docker exec -it www-10.9.0.5 bash
```

### Linux Inspection Commands

1. **`pwd`**
   - *What*: Displays working directory (`/var/www/html`).
   - *Why*: Confirms current directory position inside web container.
   - *Lab Application*: Verify active location before reviewing PHP files.

2. **`ls -la`**
   - *What*: Lists files, permissions, and directory structure.
   - *Why*: Identifies application files (`unsafe_home.php`, `unsafe_search.php`).
   - *Lab Application*: Locate vulnerable search script.

3. **`whoami` and `id`**
   - *What*: Displays user name (`root`) and numeric UID/GID (`0`).
   - *Why*: Verifies container administrative shell privileges.
   - *Lab Application*: Contrast interactive root access with `www-data` web worker process execution.

4. **`hostname` and `ip addr`**
   - *What*: Displays container hostname (`www-10.9.0.5`) and IP address (`10.9.0.5`).
   - *Why*: Verifies network interface configuration.
   - *Lab Application*: Confirm container static IP on `net-10.9.0.0-sqli`.

5. **`ps aux`**
   - *What*: Lists active process table.
   - *Why*: Inspects running daemons and application processes.
   - *Lab Application*: Identify master Apache process (`root`) and worker processes (`www-data`).

6. **`env` and `printenv`**
   - *What*: Displays environment variables.
   - *Why*: Verifies environment variables passed via Compose.
   - *Lab Application*: Check `MYSQL_HOST=10.9.0.6` environment variable.

---

## 6. Official Lab Tasks

Download official PDF handout: https://seedsecuritylabs.org/Labs_20.04/Web/Web_SQL_Injection/

- **Task 1**: Explore database structure via MySQL CLI.
- **Task 2.1**: Perform SQL injection from the login webpage (`admin'#`).
- **Task 2.2**: Perform SQL injection from command line using `curl`.
- **Task 2.3**: Append a second SQL statement.
- **Task 3.1**: Modify salary data via UPDATE injection.
- **Task 3.2**: Modify another employee's salary.
- **Task 3.3**: Modify another user's password.
- **Task 4**: Implement defensive countermeasure using prepared statements.

---

## 7. Vulnerability Root Cause and Countermeasures

### Root Cause (Unsafe String Concatenation)
```php
$sql = "SELECT * FROM credential WHERE name='$name' AND Password='$pwd'";
```

### Countermeasure (Prepared Statements)
```php
$stmt = $conn->prepare("SELECT * FROM credential WHERE name=? AND Password=?");
$stmt->bind_param("ss", $name, $pwd);
$stmt->execute();
```

---

## 8. Stop and Reset

```bash
docker compose down        # Stop containers
docker compose down -v    # Reset database state
```
