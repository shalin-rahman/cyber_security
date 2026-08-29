# Common Workflow for Every Docker-Based SEED Web Lab

## Step 1: Create a workspace

```bash
mkdir -p ~/seedlabs
cd ~/seedlabs
```

## Step 2: Download the official setup package

Download the exact `Labsetup.zip` from the official page for the selected lab.

For supported ARM environments, use the corresponding ARM package when provided.

## Step 3: Do not unpack blindly in a shared folder

The official lab instructions warn against unpacking the setup package inside shared folders. Use a normal directory inside the Linux environment.

## Step 4: Extract

```bash
unzip Labsetup.zip
cd Labsetup
```

## Step 5: Inspect before running

```bash
find . -maxdepth 2 -type f | sort
```

Look for:

```text
docker-compose.yml
Dockerfile
web application files
database files
configuration files
```

## Step 6: Read the Compose topology

```bash
cat docker-compose.yml
```

Answer:

- How many services exist?
- Which service is the vulnerable application?
- Which service stores data?
- Which ports are exposed?
- Which volumes persist data?
- Which network addresses or hostnames are used?

## Step 7: Build

Modern Docker:

```bash
docker compose build
```

Some older documentation uses:

```bash
docker-compose build
```

Use the command supported by the installed environment.

## Step 8: Start

```bash
docker compose up -d
```

If the official lab instructions intentionally use foreground mode, use:

```bash
docker compose up
```

## Step 9: Verify

```bash
docker ps
docker compose ps
docker compose logs
```

## Step 10: Enter a container

```bash
docker exec -it <container-id-or-name> bash
```

Then inspect:

```bash
hostname
ip addr
ps aux
```

## Step 11: Verify connectivity

Use harmless diagnostic commands such as:

```bash
curl -I http://<lab-host>
```

or:

```bash
getent hosts <lab-host>
```

Use the exact names and addresses specified by the official lab.

## Step 12: Complete official tasks

Follow the task order in the lab PDF. Record:

- expected behavior,
- observed behavior,
- relevant HTTP/database/server behavior,
- security explanation,
- countermeasure.

## Step 13: Stop the environment

```bash
docker compose down
```

## Step 14: Reset

Only use destructive cleanup when you understand the data impact.

Useful commands:

```bash
docker compose down
docker compose down -v
docker system df
```

`down -v` may delete named volumes and therefore reset persisted lab data.
