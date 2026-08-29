# Docker Cheat Sheet for SEED Labs

## Images

```bash
docker images
docker pull <image>
docker image inspect <image>
```

## Containers

```bash
docker ps
docker ps -a
docker logs <container>
docker exec -it <container> bash
docker stop <container>
docker start <container>
```

## Compose

```bash
docker compose build
docker compose up -d
docker compose ps
docker compose logs
docker compose logs -f
docker compose down
```

## Networks

```bash
docker network ls
docker network inspect <network>
```

## Volumes

```bash
docker volume ls
docker volume inspect <volume>
```

## Safe inspection habit

Before changing anything:

```bash
docker compose config
docker ps
docker compose logs --tail=100
```

## Useful learning habit

For every command, ask:

```text
What changed?
Which container changed?
Which network changed?
Which process is now running?
Which data persists after shutdown?
```
