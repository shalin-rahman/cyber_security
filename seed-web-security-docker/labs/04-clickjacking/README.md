# Lab 04 — Clickjacking Attack Lab

**Implementation Type**: Official SEED source adapted for Docker

Official lab manual: https://seedsecuritylabs.org/Labs_20.04/Web/Web_Clickjacking/
Textbook: Chapter 13 — Clickjacking Attack (*Computer & Internet Security*, 2nd Ed., Prof. Wenliang Du)
Lecture Sync Sitemap: [SEED Lecture & Reference Sitemap](../../docs/lectures-and-references.md#5-lab-04--clickjacking-ui-redress)
CWE Reference: [CWE-1021: Improper Restriction of Rendered UI Layers or Frames](https://cwe.mitre.org/data/definitions/1021.html)

For authorized educational use only.

> **HOST BROWSER ROUTING NOTICE**: Access Target site in host browsers via `http://localhost:10084` (or `http://www.cjlab.com:10084`) and Attacker site via `http://localhost:10085` (or `http://www.cjlab-attacker.com:10085`). Do not use internal container IPs `10.9.0.80` or `10.9.0.81` directly in host browsers.  
> **CONTAINER COMMAND FALLBACKS**: If `bash` is missing: `docker exec -it cjlab-10.9.0.80 sh`. If `ip` is missing: `hostname -i`. If `ss` is missing: `netstat -tlnp`.

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
  | Hosts file: www.cjlab.com          -> 127.0.0.1 (or localhost:10084)
  | Hosts file: www.cjlab-attacker.com -> 127.0.0.1 (or localhost:10085)
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

```bash
cd labs/04-clickjacking
.\start.ps1       # Windows PowerShell
./start.sh        # Linux / WSL2 bash
```

---

## Layer 2 — Linux Commands (inside the container)

```bash
docker exec -it cjlab-10.9.0.80 bash
cd /var/www/html
cat index.html
exit
```

---

## Layer 3 — Security Tasks

```
Target Site:   http://localhost:10084  OR  http://www.cjlab.com:10084
Attacker Site: http://localhost:10085  OR  http://www.cjlab-attacker.com:10085
```

---

## Stop and Reset

```bash
docker compose down
docker compose down -v
```
