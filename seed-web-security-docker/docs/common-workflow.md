# Common Operational Learning Workflow

This document outlines the standard 14-step learning flow designed to take students from initial security concepts down to hands-on Linux, Docker, application, and countermeasure inspection.

---

## The Standard 14-Step Learning Sequence

```
STEP 1: Understand the Security Concept
  Read the lab overview, textbook chapter, and vulnerability background.
      |
      v
STEP 2: Understand the Lab Architecture
  Review the multi-container topology, IP mapping, and domain resolution.
      |
      v
STEP 3: Understand Docker Architecture
  Examine image dependencies, port bindings, and network bridge declarations.
      |
      v
STEP 4: Start Containers
  Run ./start.sh or docker compose up -d inside the lab directory.
      |
      v
STEP 5: Inspect Docker
  Verify running containers using docker compose ps and status.sh.
      |
      v
STEP 6: Enter Linux Containers
  Spawn interactive container shell via docker exec -it <container> bash.
      |
      v
STEP 7: Inspect Linux Environment
  Execute Linux inspection commands: pwd, ls -la, ps aux, whoami, id, hostname, ip addr, env.
      |
      v
STEP 8: Inspect Application
  Navigate source code directories (/var/www/html) and configuration files.
      |
      v
STEP 9: Complete Official Lab Tasks
  Open host browser to lab domain and work through official SEED task requirements.
      |
      v
STEP 10: Inspect Logs
  Check container logs (docker compose logs -f) and internal application logs (/var/log/apache2/).
      |
      v
STEP 11: Understand Root Cause
  Analyze the unsafe code flaw causing the vulnerability.
      |
      v
STEP 12: Implement / Study Countermeasure
  Test defensive mechanisms (prepared statements, output encoding, CSRF tokens, CSP, X-Frame-Options).
      |
      v
STEP 13: Stop and Reset
  Run ./stop.sh or ./reset.sh (docker compose down -v) to restore clean state.
      |
      v
STEP 14: Document Learning
  Record attack observations, log traces, and defense verification notes.
```
