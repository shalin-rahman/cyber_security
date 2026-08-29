# Lab 05 — Shellshock Vulnerability Lab

## Learning objective

Understand how a vulnerability in a system component can become reachable through a web-facing service, and why patching and reducing exposure are critical.

## Conceptual architecture

```text
Client request
     |
     v
Web server / CGI handling
     |
     v
Shell or vulnerable component
     |
     v
Unexpected interpretation behavior
```

## Docker setup workflow

1. Open the official SEED lab page.
2. Download the official `Labsetup.zip`.
3. Extract it outside shared folders.
4. Enter `Labsetup`.
5. Inspect `docker-compose.yml` and Dockerfiles.
6. Build:

```bash
docker compose build
```

7. Start:

```bash
docker compose up -d
```

8. Verify:

```bash
docker ps
docker compose logs
```

9. Use the official lab instructions for the learning tasks.
10. Stop:

```bash
docker compose down
```


## Important environment note

Vulnerability labs involving historical software versions are environment-sensitive. Use the exact official SEED setup package and avoid replacing components with current versions unless the learning objective is specifically to study the patch difference.

## Learning process

1. Identify the vulnerable component.
2. Identify the web-facing path that reaches it.
3. Observe the vulnerable behavior only within the official isolated lab.
4. Compare vulnerable and patched behavior.
5. Study exposure reduction and upgrade strategy.

## Docker learning points

- legacy software packaged into isolated images,
- reproducible vulnerable environments,
- image/version inspection,
- container isolation boundaries.

## Success criteria

You can explain:

- which component was vulnerable,
- how it became reachable,
- why version management matters,
- why containerization does not automatically make vulnerable software safe.
