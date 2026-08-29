# SEED Labs and Docker

## Docker-only suitability

SEED Labs 2.0 significantly uses containers to simplify lab setup. Many official lab pages provide:

- `Labsetup.zip`
- sometimes `Labsetup-arm.zip`
- Docker-oriented setup
- a `docker-compose.yml`
- Dockerfiles
- a Docker manual

This makes Docker the primary lab-environment mechanism for many modern SEED Labs.

## But "Docker-only" has two meanings

### Meaning A: No prebuilt SEED VM is required

For many containerized labs, the answer is effectively yes: a compatible Linux host, physical machine, cloud VM, or non-SEED Ubuntu VM can host the containers.

### Meaning B: Docker can reproduce every SEED experiment exactly

No universal guarantee should be made. Some experiments can depend on the host kernel, privileges, network behavior, old software, CPU architecture, or GUI behavior.

## Decision table

| Lab characteristic | Docker suitability |
|---|---|
| Web application + database | Excellent |
| Multiple HTTP services | Excellent |
| Application security | Excellent |
| Crypto command-line tools | Often good |
| Basic networking topologies | Often good |
| Raw packet/kernel behavior | Verify per lab |
| Kernel vulnerabilities | VM may be preferred |
| Old OS-specific behavior | VM may be required |
| Browser/GUI interactions | Docker + host browser may be needed |
| Architecture-specific binaries | Verify AMD64 vs ARM support |

## Recommended policy for this repository

For each lab:

1. Start from the official SEED lab page.
2. Download the exact setup archive provided for the platform.
3. Read the lab PDF/manual.
4. Inspect the Docker Compose and Dockerfile files before starting.
5. Run the lab in Docker when the official package supports it.
6. Use the SEED VM or another compatible VM when Docker alone cannot reproduce the required environment.

## Platform considerations

### Intel/AMD

The official SEED Ubuntu 20.04 environment has traditionally been tested for Intel/AMD machines.

### Apple Silicon

SEED provides ARM-oriented setup packages for many labs, but support should be checked for each individual lab.

### Windows

Docker Desktop may work for container execution, but the most predictable environment for Linux-focused security labs is usually an Ubuntu VM or Linux host. Browser-based labs may additionally require host-name mappings and browser access.

## Core principle

Do not replace an official lab setup with an invented Compose file unless the goal is specifically to build a custom learning environment. For official learning results, preserve the official topology and configuration.
