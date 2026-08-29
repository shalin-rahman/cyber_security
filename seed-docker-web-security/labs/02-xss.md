# Lab 02 — Cross-Site Scripting (XSS) Attack Lab

## Learning objective

Understand how untrusted data can become executable browser content when inserted into an unsafe output context.

## Architecture

```text
User-controlled content
        |
        v
Web application
        |
        v
Stored or reflected response data
        |
        v
Victim browser interprets page
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


## Hostname configuration

Some SEED XSS setups use multiple website names mapped to the lab web-server container. Use the exact `/etc/hosts` mappings provided by the official lab documentation for the selected version.

Do not copy host mappings from another SEED lab without checking the current lab document.

## Learning process

### Step 1 — Find data entry points

Examples include:

- profile fields,
- forms,
- comments,
- request parameters.

### Step 2 — Follow data to output

```text
Input
  ->
Server processing
  ->
Storage or response generation
  ->
HTML output
  ->
Browser interpretation
```

### Step 3 — Identify output context

Consider whether the data is placed into:

- HTML text,
- an attribute,
- a URL,
- JavaScript,
- another browser context.

### Step 4 — Study defense

Focus on:

- context-aware output encoding,
- safe APIs/framework defaults,
- sanitization where appropriate,
- browser security controls.

## Docker learning points

- container-hosted web applications,
- hostname-to-container mapping,
- browser-to-container communication,
- inspecting web server logs.

## Success criteria

You can explain why input validation alone is not a universal XSS defense and why the output context matters.

## Official SEED Reference

https://seedsecuritylabs.org/Labs_20.04/Web/Web_XSS_Elgg/

Also see: `docs/07-official-sources.md`
