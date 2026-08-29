# Lab 03 — Cross-Site Request Forgery (CSRF) Attack Lab

## Learning objective

Understand how an authenticated browser can be induced to send an unwanted state-changing request and how servers verify request intent.

## Architecture

```text
Victim browser
   | \
   |  \ visits another site
   |   \
   v    v
Trusted site   Untrusted site
   ^
   |
Authenticated session
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

### Step 1 — Understand the session

```text
Login
  ->
Session created
  ->
Browser stores credential/session state
  ->
Browser sends relevant credentials with requests
```

### Step 2 — Understand request intent

A server must distinguish between:

- a request genuinely initiated by the expected application workflow;
- a request triggered from an untrusted context.

### Step 3 — Study countermeasures

Focus on:

- CSRF tokens,
- SameSite cookie settings,
- origin/referrer checks where appropriate,
- careful design of state-changing endpoints.

## Docker learning points

- multiple web services,
- separate trusted and untrusted origins,
- hostname configuration,
- browser session behavior.

## Success criteria

You can draw the complete request flow and explain where server-side verification must occur.

## Official SEED Reference

https://seedsecuritylabs.org/Labs_20.04/Web/Web_CSRF_Elgg/

Also see: `docs/07-official-sources.md`
