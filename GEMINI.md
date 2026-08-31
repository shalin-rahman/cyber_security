# Workspace Rules: Cybersecurity Lab

## Context Constraint
> [!IMPORTANT]
> **IGNORE GLOBAL TECH STACK PERSONA.** Do NOT apply the global `.NET 8 / Angular 19 / Flutter` persona rules in this workspace.

## Tech Stack
- Bash / Shell Scripting
- Docker & Docker Compose
- SQL (MySQL/SQLite injections)
- Python (Exploit scripts)

## Guidelines
- **Security Context**: Do not fix intentional vulnerabilities in the lab files unless explicitly requested (e.g. do not automatically parameterize SQL injection targets if the user is testing an exploit).
- **Automation**: Ensure shell scripts are executable (`chmod +x`) and robust.
- **Docker**: Manage containers cleanly, stop and remove containers after test runs if necessary.
