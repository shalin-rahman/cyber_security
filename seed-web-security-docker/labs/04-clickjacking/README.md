# Lab 04 — Clickjacking Attack Lab

Official lab manual: https://seedsecuritylabs.org/Labs_20.04/Web/Web_Clickjacking/
Textbook: Chapter 13 — Clickjacking Attack (*Computer & Internet Security*, Prof. Wenliang Du)

For authorized educational use only.

---

## Security Concept

Clickjacking (also known as UI Redress Attack) tricks a user into clicking a button or link on a legitimate website by overlaying a transparent iframe on top of a decoy page. The user thinks they are clicking the attacker's harmless button but actually clicks the target site's dangerous button underneath.

```
What Alice sees:                      What is actually rendered:
+----------------------------------+  +----------------------------------+
|                                  |  |  Attacker Page (visible)         |
|   WIN A FREE IPHONE!             |  |  [CLAIM YOUR FREE GIFT!] button  |
|                                  |  |                                  |
|   [CLAIM YOUR FREE GIFT!]        |  |  Target Page (transparent iframe)|
|                                  |  |  [Delete My Account] <- ACTUAL   |
+----------------------------------+  +----------------------------------+

Alice clicks "CLAIM YOUR FREE GIFT!" but actually clicks "Delete My Account"
```

Key mechanism: The `<iframe>` is set to `opacity: 0` (invisible) and positioned precisely so the dangerous button aligns with the decoy button.

---

## Container Architecture

```
HOST MACHINE
  |
  | Hosts file: www.cjlab.com          -> 10.9.0.80
  | Hosts file: www.cjlab-attacker.com -> 10.9.0.81
  |
  | Port 10084 -> cjlab-10.9.0.80:80           (target site)
  | Port 10085 -> cjlab-attacker-10.9.0.81:80  (attacker site)
  |
  Docker Bridge Network: net-10.9.0.0-clickjacking (10.9.0.0/24)
    |
    +---- cjlab-10.9.0.80            (Apache, www.cjlab.com, target portal)
    |
    +---- cjlab-attacker-10.9.0.81   (Apache, www.cjlab-attacker.com, overlay page)
```

---

## Layer 1 — Docker Commands (host terminal)

### Start the Lab

```bash
cd labs/04-clickjacking
docker compose up -d --build

# Two containers start:
# cjlab-10.9.0.80          -> target site (port 10084)
# cjlab-attacker-10.9.0.81 -> attacker overlay site (port 10085)
```

```powershell
# Windows
cd labs\04-clickjacking
docker compose up -d --build
```

### Verify Containers

```bash
docker compose ps

# NAME                       IMAGE                              STATUS    PORTS
# cjlab-10.9.0.80            seed-image-www-clickjacking        Up        0.0.0.0:10084->80/tcp
# cjlab-attacker-10.9.0.81   seed-image-www-clickjacking-attacker Up      0.0.0.0:10085->80/tcp
```

### Inspect Network

```bash
docker network inspect net-10.9.0.0-clickjacking

docker inspect -f '{{.Name}} -> {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
  cjlab-10.9.0.80 cjlab-attacker-10.9.0.81
```

### Watch Logs

```bash
# Watch requests when victim clicks on attacker page
docker compose logs -f target-website
docker compose logs -f attacker-website
```

---

## Layer 2 — Linux Commands (inside the containers)

### Open Bash in the Target Container

```bash
docker exec -it cjlab-10.9.0.80 bash
```

Prompt changes:
```
Before: PS C:\>  OR  user@host:~$
After:  root@cjlab-10.9.0.80:/#
```

```bash
whoami && hostname
# root | cjlab-10.9.0.80

ip addr show | grep "inet "
# 10.9.0.80/24

# Inspect the target page HTML (the one with the real dangerous button)
cd /var/www/html
cat index.html

# Find the dangerous action button in the source
grep -n "button\|delete\|action" index.html

# Watch requests arrive when victim clicks through iframe
tail -f /var/log/apache2/access.log

exit
```

### Open Bash in the Attacker Container

```bash
docker exec -it cjlab-attacker-10.9.0.81 bash
```

Prompt changes:
```
Before: PS C:\>  OR  user@host:~$
After:  root@cjlab-attacker-10.9.0.81:/#
```

```bash
whoami && hostname
# root | cjlab-attacker-10.9.0.81

cd /var/www/html
cat index.html

# The attack mechanism is in these CSS and HTML elements:
grep -n "opacity\|iframe\|z-index\|position" index.html

# Note how the iframe is:
# - Set to opacity: 0.0 (invisible)
# - Positioned over the decoy button via absolute positioning
# - Contains www.cjlab.com as its src

exit
```

---

## Layer 3 — Security Tasks

### Configure Hostnames

Windows (PowerShell as Administrator):
```powershell
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
Add-Content $hostsFile "10.9.0.80   www.cjlab.com"
Add-Content $hostsFile "10.9.0.81   www.cjlab-attacker.com"
```

Linux / WSL2:
```bash
echo "10.9.0.80   www.cjlab.com"          | sudo tee -a /etc/hosts
echo "10.9.0.81   www.cjlab-attacker.com" | sudo tee -a /etc/hosts
```

### Lab Workflow

```
Step 1: Visit the target site first to understand the legitimate UI
  http://www.cjlab.com       OR   http://localhost:10084
  Observe: "Delete My Account" button location on the page

Step 2: Visit the attacker site
  http://www.cjlab-attacker.com   OR   http://localhost:10085
  Observe: A decoy "CLAIM YOUR FREE GIFT" button

Step 3: Click the decoy button
  Notice that the target site's action fires (the dangerous button was clicked)
```

### Task 1 — Observe the iframe Overlay Using DevTools

```
1. Open http://localhost:10085 in the browser
2. Press F12 to open DevTools
3. In the Elements/Inspector panel, expand the HTML structure
4. Find the <iframe> element — note its opacity: 0.0 style
5. In DevTools, change opacity to 0.5 to make the overlay visible
   Right-click the iframe element -> Edit attribute -> change opacity value
6. You can now see the transparent target page overlaid on the attacker page
```

### Task 2 — Implement X-Frame-Options Defense

The target site can prevent being loaded inside an iframe by setting an HTTP response header:

```
X-Frame-Options: DENY        -> blocks all iframe embedding
X-Frame-Options: SAMEORIGIN  -> only allows embedding by same domain
```

Add this header to the Apache configuration inside the target container:

```bash
docker exec -it cjlab-10.9.0.80 bash

# Edit Apache config
cat /etc/apache2/sites-enabled/000-default.conf

# Add the header inside the VirtualHost block
echo 'Header always set X-Frame-Options "DENY"' >> /etc/apache2/sites-enabled/000-default.conf

# Reload Apache
service apache2 reload

exit
```

Now reload `http://localhost:10085`. The iframe should fail to load the target site.

Verify the header is sent:
```bash
# Linux/macOS
curl -I http://localhost:10084 | grep X-Frame

# Windows PowerShell
curl.exe -I http://localhost:10084
# Look for: X-Frame-Options: DENY
```

### Task 3 — Content Security Policy frame-ancestors

Modern alternative to X-Frame-Options:

```bash
docker exec -it cjlab-10.9.0.80 bash
echo "Header always set Content-Security-Policy \"frame-ancestors 'none'\"" >> \
  /etc/apache2/sites-enabled/000-default.conf
service apache2 reload
exit
```

---

## Stop and Reset

```bash
docker compose down
docker compose down -v && docker compose up -d --build
```

```powershell
# Windows
docker compose down -v
docker compose up -d --build
```

---

## Key File Locations

| File | Container | Path |
|------|-----------|------|
| Target site HTML | `cjlab-10.9.0.80` | `/var/www/html/index.html` |
| Attacker overlay HTML | `cjlab-attacker-10.9.0.81` | `/var/www/html/index.html` |
| Target Apache config | `cjlab-10.9.0.80` | `/etc/apache2/sites-enabled/000-default.conf` |
| Target access log | `cjlab-10.9.0.80` | `/var/log/apache2/access.log` |
