# Troubleshooting Docker-Based SEED Labs

## Problem: container exits immediately

```bash
docker ps -a
docker logs <container>
```

Check the process configured by the image or Compose service.

## Problem: image build fails

```bash
docker compose build --no-cache
```

Also inspect:

- Dockerfile base image availability
- network access for package installation
- CPU architecture compatibility
- obsolete package repositories

## Problem: web page does not open

Check:

```bash
docker ps
docker compose logs
```

Then verify:

- container is running,
- required port is exposed,
- hostname mapping is correct,
- browser is using the expected host,
- the web service is listening inside the container.

## Problem: hostname does not resolve

Check:

```bash
getent hosts <hostname>
```

Some SEED web labs require entries in `/etc/hosts` because multiple lab websites may be represented by container addresses.

Use the exact mappings documented by the selected lab.

## Problem: database data disappears

Check whether the lab uses a bind mount or named volume.

```bash
docker volume ls
```

Read `docker-compose.yml` and identify persistence.

## Problem: cannot enter a container

First list running containers:

```bash
docker ps
```

Then:

```bash
docker exec -it <container> bash
```

If the container has no `bash`, try:

```bash
docker exec -it <container> sh
```

## Problem: ARM/Apple Silicon compatibility

Verify that the selected SEED lab explicitly provides ARM support. If it does not, do not assume an AMD64 image will run correctly without emulation or modification.

## Debugging sequence

```text
Application problem?
      |
      v
Is container running?
      |
      v
Are logs clean?
      |
      v
Is the network reachable?
      |
      v
Does hostname resolution work?
      |
      v
Is the application listening?
      |
      v
Is the lab configuration correct?
```
