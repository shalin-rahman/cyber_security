# Lab 04 — Clickjacking Attack Lab

## Learning objective

Understand UI redress attacks, where a victim is tricked into interacting with an interface different from the one they believe they are using.

## Conceptual architecture

```text
Victim Browser
      |
      v
Attacker-controlled presentation
      |
      +-- embedded/overlaid content
              |
              v
          Target website
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


## Learning process

1. Understand how browser frames work.
2. Observe how UI layering can misrepresent the true click target.
3. Study frame embedding restrictions.
4. Study server/browser protections.

## Countermeasure concepts

Focus on:

- `Content-Security-Policy` frame restrictions,
- frame embedding policies,
- application-side UI confirmation for sensitive actions.

## Docker learning points

- multiple web origins,
- browser access to container-hosted applications,
- hostname and port topology.

## Success criteria

You can explain why a server-side application can be secure in one sense but still be exposed to a browser UI-deception attack if framing policies are missing.
