# Lab 01 — SQL Injection Attack Lab

## Learning objective

Understand how unsafe construction of database queries can allow application input to change the meaning of a query, and how secure query APIs prevent this class of problem.

## Architecture

```text
Browser / Client
      |
      | HTTP request with input
      v
Vulnerable Web Application
      |
      | Database query
      v
Database
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


## What to inspect

Before performing any official task, inspect:

- web application source files,
- database configuration,
- Compose service definitions,
- database persistence mounts.

## Learning process

### Step 1 — Trace input

```text
User input
    |
    v
HTTP request
    |
    v
Application variable
    |
    v
Database API
    |
    v
Query execution
```

### Step 2 — Identify the root cause

Ask whether data is being treated as data or accidentally interpreted as query syntax.

### Step 3 — Observe the effect

Use only the official lab tasks and targets. Record how application behavior changes and why.

### Step 4 — Study the defense

Compare:

```text
Unsafe query construction
        vs
Parameterized/prepared query execution
```

## Docker learning points

- multi-container application topology,
- database persistence,
- container shell access,
- application and database separation,
- logs and network inspection.

## Success criteria

You can explain:

1. where untrusted input enters;
2. how it reaches the database;
3. why unsafe query construction is dangerous;
4. how parameterized queries change the data flow.

## Official SEED Reference

https://seedsecuritylabs.org/Labs_20.04/Web/Web_SQL_Injection/

Also see: `docs/07-official-sources.md`
