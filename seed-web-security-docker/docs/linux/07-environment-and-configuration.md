# Linux Module 07 — Environment Variables and Configuration

This document explains environment variable passing, shell expansion, and how environment variables configure web applications inside Docker containers.

---

## 1. Environment Variable Architecture in Docker

Docker Compose injects environment variables into container process environments upon startup:

```
docker-compose.yml
  environment:
    - MYSQL_HOST=10.9.0.6
    - MYSQL_ROOT_PASSWORD=dees
           |
           | Passes variables at container creation
           v
Container Shell Environment (www-10.9.0.5)
  $_ENV['MYSQL_HOST'] -> Read by PHP application code
```

---

## 2. Command Reference

### Command 1: `env`

- **What it does**: Prints all exported environment variables in the current shell session.
- **Why it matters**: Verifies configuration values passed to the container at launch.
- **SEED Lab Application**: Run `env` inside `www-10.9.0.5` to verify `MYSQL_HOST=10.9.0.6`.

### Command 2: `printenv <VAR>`

- **What it does**: Prints the value of a specific environment variable.
- **Why it matters**: Checks individual settings without scanning the entire variable list.
- **SEED Lab Application**: Run `printenv MYSQL_HOST` inside the SQL Injection container.

### Command 3: `export VAR=value`

- **What it does**: Sets and exports a variable to child processes in the current shell session.
- **Why it matters**: Used in command-line experiments and shell scripting.
- **SEED Lab Application**: In Task 1 of the Shellshock lab, export a function definition using `export foo='() { :;}; echo VULNERABLE'` to test Bash parsing.

### Relevance to Shellshock Vulnerability (CVE-2014-6271)
The Shellshock lab demonstrates the danger of automatic environment variable parsing. Apache CGI passes HTTP request headers (`User-Agent`, `Referer`, `Cookie`) as environment variables (`HTTP_USER_AGENT`, `HTTP_REFERER`, `HTTP_COOKIE`) to the CGI script shell. Vulnerable Bash versions parse function declarations within these environment variables and improperly execute trailing commands.
