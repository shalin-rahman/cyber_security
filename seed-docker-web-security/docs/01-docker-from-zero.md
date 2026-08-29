# Docker From Zero for Security Labs

## 1. Why Docker is useful

A security lab often needs several machines or services:

```text
Browser / Client
       |
       v
Vulnerable Web Application
       |
       v
Database
```

Docker allows these components to run as isolated containers on one host.

## 2. Image vs Container

```text
Docker Image
   |
   | create/run
   v
Docker Container
```

An image is a reusable template. A container is a running instance created from that template.

Example:

```bash
docker pull ubuntu
docker run -it ubuntu bash
```

## 3. What happens when `docker run` is executed?

```text
Docker CLI
   |
   v
Docker Engine
   |
   +-- Image available?
          |
          +-- No -> pull image
          |
          +-- Yes
                  |
                  v
             Create container
                  |
                  v
             Create namespaces/isolation
                  |
                  v
             Configure filesystem/network
                  |
                  v
             Start container process
```

A container is not a full virtual machine. Containers normally share the host kernel while isolating processes, filesystems, networking, and other resources.

## 4. Dockerfile

A Dockerfile defines how an image is built.

```dockerfile
FROM nginx:latest
COPY index.html /usr/share/nginx/html/index.html
```

Build:

```bash
docker build -t my-web-site .
```

Run:

```bash
docker run -p 8080:80 my-web-site
```

## 5. Port mapping

```text
Browser
   |
   | http://localhost:8080
   v
Host port 8080
   |
   v
Container port 80
   |
   v
Web server
```

Example:

```bash
docker run -p 8080:80 nginx
```

## 6. Docker networks

Containers can communicate through Docker networks.

```text
Docker Network
|
+-- web
|     web:80
|
+-- database
      database:3306
```

Create a network:

```bash
docker network create security-net
```

## 7. Volumes

Containers are normally disposable. A volume or bind mount keeps data outside the disposable container layer.

```text
Host directory
      |
      v
Docker mount
      |
      v
Container directory
```

This is especially important for databases and lab modifications.

## 8. Docker Compose

Compose describes multiple containers as one application.

Conceptual example:

```yaml
services:
  web:
    build: ./web
    ports:
      - "8080:80"

  database:
    image: mysql:8
```

Start:

```bash
docker compose up -d
```

Stop:

```bash
docker compose down
```

## 9. Commands to learn first

```bash
docker images
docker ps
docker ps -a
docker run -it ubuntu bash
docker exec -it <container> bash
docker logs <container>
docker network ls
docker network inspect <network>
docker compose build
docker compose up -d
docker compose logs
docker compose down
```

## 10. Security-lab mental model

When a lab is containerized, think of it as a miniature infrastructure:

```text
Attacker/Browser
      |
      | HTTP
      v
Web Application Container
      |
      | SQL/API/internal traffic
      v
Database or Backend Container
```

Your goal is to understand both:

1. the security weakness; and
2. the infrastructure carrying the traffic.
