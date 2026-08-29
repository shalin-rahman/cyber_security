# Security Policy & Educational Scope

## Educational Intent Notice

All applications, scripts, and configurations in this repository are designed strictly for **authorized educational research, lab practice, and defensive security training**.

The vulnerabilities contained herein (SQL Injection, Cross-Site Scripting, CSRF, Clickjacking, Shellshock) exist inside isolated Docker container bridge networks on your local host system.

---

## Reporting Vulnerabilities in Repository Infrastructure

If you discover a security flaw in the orchestration scripts (`.sh` / `.ps1`), environment validators, or container configuration files that could expose host machines beyond the intended Docker bridge boundaries:

1. **Do not create a public GitHub Issue.**
2. Report findings responsibly by contacting the repository maintainers.
3. Provide details including OS environment, Docker Desktop / Engine version, steps to reproduce, and potential host impact.

---

## Safety Guidelines for Students & Educators

- Always run lab containers on local bridge networks (`10.9.0.0/24`).
- Do not expose lab container host ports (`10080`-`10086`) to untrusted public networks or public IP addresses.
- Do not reuse default database passwords (`dees`, `seedubuntu`) in production environments.
