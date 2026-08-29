# Changelog

All notable changes to the SEED Web Security Docker Learning Environment will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2026-08-29

### Added
- Standardized 3-Layer Learning Framework (Layer 1: Docker, Layer 2: Linux container user space, Layer 3: Web security tasks).
- Added `OFFICIAL-COMPATIBILITY.md` specification across all 5 lab modules.
- Created `doctor.ps1` and `doctor.sh` environment diagnostics scripts.
- Added GitHub Actions CI workflows for markdown validation and Docker compose linting.
- Added comprehensive resource requirement matrices (Minimum, Recommended, Advanced).
- Created root governance files: `LICENSE`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `CHANGELOG.md`.

### Refactored
- Consolidated dual project folders into a single canonical `seed-web-security-docker` directory.
- Standardized all 40 lab orchestration scripts (`setup`, `start`, `stop`, `reset` across `.sh` and `.ps1`).
- Rewrote root `README.md` and lab `README.md` files with web-compatible relative Markdown links.
- Replaced emoji indicators with plain text status badges (`[PASS]`, `[WARN]`, `[FAIL]`, `[done]`).

---

## [1.0.0] - 2026-08-01

### Initial Release
- Initial baseline Docker environments for SEED Web Security Labs (SQL Injection, XSS, CSRF, Clickjacking, Shellshock).
