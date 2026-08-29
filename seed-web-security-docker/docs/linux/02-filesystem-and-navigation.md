# Linux Module 02 — Filesystem Hierarchy and File Navigation

This document details the Linux filesystem structure within SEED web security containers and provides command-level navigation guidance.

---

## 1. Container Filesystem Structure

SEED web security containers follow standard Linux FHS (Filesystem Hierarchy Standard):

```
/
├── bin/          Essential user binaries (bash, ls, cat)
├── etc/          System and service configurations
│   ├── apache2/  Apache web server configuration
│   └── mysql/    MySQL database configuration
├── usr/          User programs and CGI binaries
│   └── lib/cgi-bin/  CGI scripts (Shellshock lab)
├── var/          Variable data directories
│   ├── log/      System, Apache, and MySQL log files
│   ├── lib/mysql Database storage files
│   └── www/html/ Web application source files (PHP, Elgg)
```

---

## 2. Command Reference

### Command 1: `cd`

- **What it does**: Changes the current working directory.
- **Why it matters**: Allows navigating between web source directories, configuration folders, and log locations.
- **SEED Lab Application**: Navigate to `/var/www/html` inside the SQL Injection container to locate index and search source code files.

### Command 2: `find`

- **What it does**: Searches directory trees for files matching specified criteria (name, permissions, type).
- **Why it matters**: Locates specific application files, CGI scripts, or configuration templates quickly.
- **SEED Lab Application**: In the Shellshock lab, run `find / -name "*.cgi"` to locate vulnerable CGI scripts (`vul.cgi` and `safe.cgi`).

### Command 3: `cat`

- **What it does**: Concatenates and prints file contents to standard output.
- **Why it matters**: Allows reviewing source code, configuration settings, and script files.
- **SEED Lab Application**: Run `cat /usr/lib/cgi-bin/vul.cgi` inside `shellshock-10.9.0.80` to inspect the shebang line pointing to `#!/bin/bash_shellshock`.

### Command 4: `grep`

- **What it does**: Searches text or files for lines matching a pattern or regular expression.
- **Why it matters**: Pinpoints vulnerable code lines, SQL query definitions, or configuration parameters.
- **SEED Lab Application**: Run `grep -rn "SELECT" /var/www/html/` inside the SQL Injection container to identify where raw SQL queries are constructed.

### Command 5: `head` and `tail`

- **What it does**: Displays the top (`head`) or bottom (`tail`) lines of a text file.
- **Why it matters**: Enables quick inspection of large log files or database dumps without clogging the terminal output.
- **SEED Lab Application**: Run `tail -n 20 /var/log/apache2/access.log` to inspect recent incoming HTTP requests.
