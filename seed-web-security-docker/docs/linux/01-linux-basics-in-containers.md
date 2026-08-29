# Linux Basics Inside Docker Containers

Docker containers run an isolated Linux user space. When you enter a container shell, you are interacting with a real Linux environment. This document covers the Linux commands you will use in every lab.

---

## 1. Entering a Container

```bash
# Open an interactive bash shell inside a running container
docker exec -it www-10.9.0.5 bash

# Your prompt changes to show you are inside the container:
# root@www-10.9.0.5:/#

# To exit back to your host:
exit
```

---

## 2. Identity and User Context

```bash
# Who is this process running as?
whoami
# Output: root

# Show user ID, group ID, and supplementary groups
id
# Output: uid=0(root) gid=0(root) groups=0(root)

# Note: containers often run as root for simplicity.
# In production, running as a non-root user is a security best practice.
```

---

## 3. Hostname and Network Identity

```bash
# Show this container's hostname (set in docker-compose.yml as container_name)
hostname
# Output: www-10.9.0.5

# Show all network interfaces and IP addresses
ip addr show
# Look for eth0 with the container's static IP (e.g., 10.9.0.5/24)

# Shorter alias for IP addresses only
hostname -I
# Output: 10.9.0.5

# Test connectivity to the database container
ping 10.9.0.6
```

---

## 4. Filesystem Navigation

```bash
# Show current working directory
pwd

# List files in current directory (long format with permissions)
ls -la

# Navigate to the web application root
cd /var/www/html
ls -la
# You will see: index.php (the vulnerable web application)

# View a file contents
cat index.php

# View with line numbers
cat -n index.php

# View large files page by page
less index.php    # press 'q' to quit

# Search for a string inside a file
grep "SELECT" index.php
grep -n "password" index.php    # -n shows line numbers

# Find a file by name
find / -name "php.ini" 2>/dev/null
find /etc -name "*.conf"
```

---

## 5. Process Inspection

```bash
# Show all running processes in the container
ps aux
# Columns: USER, PID, %CPU, %MEM, COMMAND
# You should see Apache processes: /usr/sbin/apache2 -DFOREGROUND

# Show process tree
ps aux --forest

# Show processes sorted by memory
ps aux --sort=-%mem

# Find the PID of a specific process
pgrep apache2
pgrep mysql
```

---

## 6. File Permissions

```bash
# Interpret permission string from 'ls -la' output:
# Example: -rw-r--r-- 1 root www-data 4096 Jan 01 index.php
#           ^           ^    ^
#           |           |    group owner
#           |           owner
#           permission bits (r=read, w=write, x=execute)

# Change file permissions
chmod 644 /var/www/html/index.php   # Owner: rw, Group: r, Others: r
chmod 755 /usr/lib/cgi-bin/vul.cgi  # Owner: rwx, Group: rx, Others: rx

# Change file owner
chown www-data:www-data /var/www/html/index.php
```

---

## 7. Environment Variables

```bash
# Show all environment variables
env

# Key variables to look for in lab containers:
# MYSQL_HOST=10.9.0.6         (tells web app where MySQL is)
# MYSQL_ROOT_PASSWORD=dees    (MySQL root password)

# Show a specific environment variable
echo $MYSQL_HOST

# Set a temporary environment variable (lost when container exits)
export MY_VAR=hello
echo $MY_VAR
```

---

## 8. Logs

```bash
# Apache access log — every HTTP request that hits the server
cat /var/log/apache2/access.log
tail -f /var/log/apache2/access.log    # stream in real time

# Apache error log — PHP errors, connection failures
cat /var/log/apache2/error.log
tail -f /var/log/apache2/error.log

# MySQL log (inside mysql container)
cat /var/log/mysql/error.log
```

From the host (without entering the container):
```bash
# Stream Apache logs from host
docker exec -it www-10.9.0.5 tail -f /var/log/apache2/access.log

# Use Docker's own logging
docker logs -f www-10.9.0.5
docker compose logs -f www
```

---

## 9. Apache Web Server Commands

```bash
# Check Apache version
apache2 -v

# Check Apache configuration syntax
apache2ctl configtest

# List enabled Apache modules
apache2ctl -M

# View Apache virtual host configuration
cat /etc/apache2/sites-enabled/000-default.conf

# Reload Apache configuration (without restarting)
service apache2 reload

# View what port Apache is listening on
ss -tlnp | grep apache2
```

---

## 10. MySQL Client Commands (Inside mysql Container)

```bash
# Enter MySQL container
docker exec -it mysql-10.9.0.6 bash

# Connect to MySQL
mysql -u root -pdees

# Inside MySQL shell:
SHOW DATABASES;
USE sqllab_users;
SHOW TABLES;
DESCRIBE credential;
SELECT * FROM credential;
SELECT Name, Salary FROM credential WHERE Name = 'alice';

# Exit MySQL
EXIT;

# Exit container
exit
```

---

## 11. Disk and System

```bash
# Check disk space usage
df -h

# Check directory size
du -sh /var/www/html

# Check system uptime and load
uptime
```
