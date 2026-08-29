# Contributing to Cybersecurity Learning Environment

Thank you for your interest in contributing! This project provides a structured, Docker-first learning environment combining Linux systems commands, container management, network routing, web architecture, and cybersecurity lab exercises.

---

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## How You Can Contribute

1. **Improving Learning Documentation**:
   - Refining Linux container command explanations.
   - Adding step-by-step countermeasure walkthroughs.
   - Clarifying architectural and data-flow diagrams.

2. **Enhancing Lab Automation**:
   - Adding environment pre-flight diagnostics to `scripts/doctor.ps1` and `scripts/doctor.sh`.
   - Improving container teardown and resource reset commands.

3. **Fixing Issues**:
   - Reporting and resolving container startup errors or host port conflicts.
   - Improving Windows PowerShell and Linux cross-platform script parity.

---

## Contribution Workflow

1. Fork the repository and create a feature branch (`git checkout -b feature/improved-documentation`).
2. Verify all markdown files follow formatting standards (plain text, no emojis, clean headers).
3. Test all `.sh` and `.ps1` scripts on Windows 10/11 PowerShell and Linux/WSL2 environments.
4. Ensure `OFFICIAL-COMPATIBILITY.md` and `README.md` files are updated for any lab changes.
5. Submit a Pull Request detailing the purpose and testing verification performed.

---

## Formatting Guidelines

- Maintain the 3-Layer Learning Framework structure (Layer 1 Docker, Layer 2 Linux inside container, Layer 3 Security Tasks).
- Use standard GitHub Flavored Markdown with clean text indicators (`[PASS]`, `[WARN]`, `[FAIL]`, `[done]`).
- Use relative Markdown links for all repository references.
