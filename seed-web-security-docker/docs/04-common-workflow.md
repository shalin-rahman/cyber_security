# Documentation Module 04 — Standard Lab Workflow

This module outlines the standard operational sequence for selecting, launching, executing, and tearing down SEED lab environments.

---

## 1. Standard Workflow Sequence

```
1. Environment Check
   Execute check-environment script to verify Docker daemon status.
      |
      v
2. Lab Selection
   Navigate to the chosen lab directory (e.g., labs/01-sql-injection/).
      |
      v
3. Hostname Configuration
   Verify /etc/hosts contains required domain-to-IP mappings.
      |
      v
4. Setup Execution
   Run ./setup.sh (or .\setup.ps1) to pull Docker images.
      |
      v
5. Container Launch
   Run ./start.sh (or docker compose up -d).
      |
      v
6. Environment Verification
   Verify container states using docker compose ps and status.sh.
      |
      v
7. Lab Exercise Execution
   Open host browser, access target URL, and perform SEED manual tasks.
      |
      v
8. Container Teardown
   Run ./stop.sh (or docker compose down).
      |
      v
9. Environment Reset (Optional)
   Run ./reset.sh (or docker compose down -v) to restore clean database.
```

---

## 2. Step-by-Step Guidance

### Step 1: Pre-flight Verification
Run `scripts/check-environment.sh` (or `scripts/check-environment.ps1`). Confirm all items pass.

### Step 2: Selecting and Starting a Lab
```bash
cd labs/01-sql-injection
./setup.sh
./start.sh
```

### Step 3: Performing Official Tasks
Follow the task procedures detailed in each lab's `README.md` and the official SEED PDF handout.

### Step 4: Observing Application and Container Logs
To monitor incoming requests or PHP errors in real time:
```bash
docker compose logs -f
```

### Step 5: Teardown and Cleanup
When lab exercises are complete, stop the container set to free system memory:
```bash
./stop.sh
```
