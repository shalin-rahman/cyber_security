# Documentation Module 05 — Troubleshooting and Diagnostics Guide

This module provides systematic diagnostic sequences and solutions for common issues encountered when running the Docker SEED labs.

---

## 1. Systematic Diagnostic Sequence

```
Issue Reported: Web Application Not Reachable / Error Page
  |
  +---> 1. Check Container State
  |        Run: docker compose ps
  |        If STATUS is not "running", check logs via: docker compose logs <service>
  |
  +---> 2. Verify Port Forwarding
  |        Run: docker ps
  |        Ensure host port (e.g., 10080) maps to container port 80.
  |
  +---> 3. Check Hostname Resolution
  |        Run: ping www.seed-server.com
  |        Ensure IP resolves correctly according to /etc/hosts entries.
  |
  +---> 4. Check Internal Container Health
  |        Run: docker exec -it <container> curl -I http://localhost
  |        Verify Apache / PHP returns HTTP 200 OK internally.
  |
  +---> 5. Inspect Database Connectivity
           Run: docker exec -it mysql-10.9.0.6 mysql -u root -pdees
           Ensure MySQL daemon is active and database tables are loaded.
```

---

## 2. Common Symptoms and Solutions

### Issue 1: `docker compose up` fails with "port already allocated"
**Cause:** Another service on your host is listening on port `10080`, `10081`, etc.  
**Solution:** Identify and stop the conflicting process, or modify the host port binding in `docker-compose.yml`:
```yaml
ports:
  - "10088:80"  # Change host port from 10080 to 10088
```

### Issue 2: Browser displays Apache default page instead of Elgg
**Cause:** Accessing the lab via `http://localhost:10081` instead of `http://www.seed-server.com`.  
**Solution:** Elgg uses VirtualHost definitions matching `www.seed-server.com`. Access the site strictly via the configured domain name after updating `/etc/hosts`.

### Issue 3: MySQL container exits continuously (`code 137` or `OOMKilled`)
**Cause:** Out Of Memory (OOM) killer terminated MySQL due to insufficient RAM allocated to Docker.  
**Solution:** Increase Docker memory allocation in Docker Desktop settings or `.wslconfig` to at least 6 GB.

### Issue 4: "Table `sqllab_users.credential` doesn't exist"
**Cause:** Database container was started before volume initialization completed.  
**Solution:** Force volume recreation:
```bash
docker compose down -v
docker compose up -d
```

### Issue 5: Shellshock payload does not execute (returns HTTP 200 without command output)
**Cause:** Using `safe.cgi` instead of `vul.cgi`, or host firewall blocking header transmission.  
**Solution:** Verify request target is `/cgi-bin/vul.cgi` and user-agent string formatting matches exact syntax:
```bash
curl -A "() { :;}; echo Content-Type: text/plain; echo; /bin/cat /etc/passwd" http://www.seedlab-shellshock.com/cgi-bin/vul.cgi
```
