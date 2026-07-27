# Lab Manual – Experiment 5
## Course: Containerization and DevOps (CS-4001)
### Topic: Docker – Volumes, Environment Variables, Monitoring & Networks



---

## 1. Objective & Learning Outcomes
After completing this laboratory experiment, students will be able to:
1. Understand the ephemeral nature of container filesystems and apply **Docker Volumes** (anonymous, named, and bind mounts) for persistent data storage.
2. Configure containers dynamically using **Environment Variables** via `-e` flags, `--env-file`, and Dockerfile `ENV` directives.
3. Monitor container health, resource consumption, and runtime events using `docker stats`, `docker top`, `docker logs`, `docker inspect`, and `docker events`.
4. Create and manage **Docker Networks** (bridge, host, none, overlay) enabling secure inter-container DNS-based communication.
5. Architect a complete multi-container application stack (Flask + PostgreSQL + Redis) integrating volumes, environment variables, custom networks, and monitoring.

---

## 2. Prerequisites
- Docker Engine / Docker Desktop installed and operational.
- Familiarity with terminal command-line operations and basic networking concepts (ports, DNS, subnets).
- Python Flask and basic SQL knowledge (for the real-world example).

---

## Part 1: Docker Volumes – Persistent Data Storage



### Lab 1: Understanding Data Persistence

#### The Problem: Container Data is Ephemeral
By default, any data written inside a container's writable layer is **lost** when the container is removed.

```bash
# Create a container that writes data
docker run -it --name test-container ubuntu /bin/bash

# Inside container:
mkdir /data
echo "Hello World" > /data/message.txt
cat /data/message.txt  # Shows "Hello World"
exit

# Restart container
docker start test-container
docker exec test-container cat /data/message.txt
# ERROR: File doesn't exist! Data was lost.
```

> **Solution: Docker Volumes** – Volumes exist outside the container's writable layer on the host filesystem, persisting data across container restarts, removals, and replacements.

![Terminal Screenshot – Ephemeral Data Problem & Volume Types](./step1_volumes_types.jpg)

---

### Lab 2: Volume Types

#### 1. Anonymous Volumes
```bash
docker run -d -v /app/data --name web1 nginx
docker volume ls
docker inspect web1 | grep -A 5 Mounts
```

#### 2. Named Volumes (Recommended for Production)
```bash
docker volume create mydata
docker run -d -v mydata:/app/data --name web2 nginx
docker volume ls
docker volume inspect mydata
```

#### 3. Bind Mounts (Host Directory Mapping)
```bash
mkdir ~/myapp-data
docker run -d -v ~/myapp-data:/app/data --name web3 nginx
echo "From Host" > ~/myapp-data/host-file.txt
docker exec web3 cat /app/data/host-file.txt
# Shows: From Host
```

---

### Lab 3: Practical Volume Examples

#### Example 1: Database with Persistent Storage
```bash
docker run -d --name mysql-db \
  -v mysql-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=secret mysql:8.0

docker stop mysql-db && docker rm mysql-db

# New container with same volume - data preserved!
docker run -d --name new-mysql \
  -v mysql-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=secret mysql:8.0
```

#### Example 2: Web App with Configuration Files
```bash
mkdir ~/nginx-config
echo 'server {
    listen 80;
    server_name localhost;
    location / {
        return 200 "Hello from mounted config!";
    }
}' > ~/nginx-config/nginx.conf

docker run -d --name nginx-custom -p 8080:80 \
  -v ~/nginx-config/nginx.conf:/etc/nginx/conf.d/default.conf nginx

curl http://localhost:8080
# Output: Hello from mounted config!
```

![Terminal Screenshot – Practical MySQL & NGINX Volume Examples](./step2_volumes_practical.jpg)

---

### Lab 4: Volume Management Commands


```bash
docker volume ls                    # List all volumes
docker volume create app-volume     # Create a volume
docker volume inspect app-volume    # Inspect volume details
docker volume prune                 # Remove unused volumes
docker volume rm volume-name        # Remove specific volume
docker cp local-file.txt container-name:/path/in/volume  # Copy files
```

---

## Part 2: Environment Variables



### Lab 1: Setting Environment Variables



#### Method 1: Using `-e` Flag
```bash
docker run -d --name app1 \
  -e DATABASE_URL="postgres://user:pass@db:5432/mydb" \
  -e DEBUG="true" -p 3000:3000 my-node-app
```

#### Method 2: Using `--env-file`
```bash
echo "DATABASE_HOST=localhost" > .env
echo "DATABASE_PORT=5432" >> .env
echo "API_KEY=secret123" >> .env

docker run -d --env-file .env --name app2 my-app
```

#### Method 3: In Dockerfile
```dockerfile
ENV NODE_ENV=production
ENV PORT=3000
ENV APP_VERSION=1.0.0
```

---

### Lab 2: Environment Variables in Applications



#### Python Flask Example
```python
import os
from flask import Flask

app = Flask(__name__)
db_host = os.environ.get('DATABASE_HOST', 'localhost')
debug_mode = os.environ.get('DEBUG', 'false').lower() == 'true'
api_key = os.environ.get('API_KEY')

@app.route('/config')
def config():
    return {
        'db_host': db_host,
        'debug': debug_mode,
        'has_api_key': bool(api_key)
    }

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=debug_mode)
```

#### Dockerfile with Environment Variables


```dockerfile
FROM python:3.9-slim
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
ENV PORT=5000
ENV DEBUG=false
EXPOSE 5000
CMD ["python", "app.py"]
```

---

### Lab 3: Test Environment Variables


```bash
docker run -d --name flask-app -p 5000:5000 \
  -e DATABASE_HOST="prod-db.example.com" \
  -e DEBUG="true" -e PORT="8080" flask-app

docker exec flask-app env
docker exec flask-app printenv DATABASE_HOST
curl http://localhost:5000/config
```

![Terminal Screenshot – Environment Variables (-e, --env-file, Flask)](./step3_env_variables.jpg)

---

## Part 3: Docker Monitoring



### Lab 1: `docker stats` – Real-time Container Metrics
```bash
docker stats
docker stats container1 container2
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
docker stats --no-stream
docker stats --all
docker stats --format json --no-stream
```

### Lab 2: `docker top` – Process Monitoring
```bash
docker top container-name
docker top container-name -ef
ps aux | grep docker
```

### Lab 3: `docker logs` – Application Logs
```bash
docker logs container-name
docker logs -f container-name
docker logs --tail 100 container-name
docker logs -t container-name
docker logs --since 2024-01-15 container-name
docker logs -f --tail 50 -t container-name
```

![Terminal Screenshot – docker stats, docker top, docker logs](./step4_monitoring.jpg)

### Lab 4: Container Inspection
```bash
docker inspect container-name
docker inspect --format='{{.State.Status}}' container-name
docker inspect --format='{{.NetworkSettings.IPAddress}}' container-name
docker inspect --format='{{.Config.Env}}' container-name
docker inspect --format='{{.HostConfig.Memory}}' container-name
```

### Lab 5: Events Monitoring
```bash
docker events
docker events --filter 'type=container'
docker events --filter 'event=start'
docker events --filter 'event=die'
docker events --since '2024-01-15'
docker events --format '{{.Type}} {{.Action}} {{.Actor.Attributes.name}}'
```

### Lab 6: Practical Monitoring Script
```bash
#!/bin/bash
echo "=== Docker Monitoring Dashboard ==="
echo "Time: $(date)"

echo "1. Running Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo "2. Resource Usage:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

echo "3. Recent Events:"
docker events --since '5m' --until '0s' --format '{{.Time}} {{.Type}} {{.Action}}' | tail -5

echo "4. System Info:"
docker system df
```

![Terminal Screenshot – Docker Events & Monitoring Dashboard](./step5_events_dashboard.jpg)

---

## Part 4: Docker Networks



### Lab 1: Understanding Docker Network Types
```bash
docker network ls
# NETWORK ID     NAME      DRIVER    SCOPE
# abc123         bridge    bridge    local
# def456         host      host      local
# ghi789         none      null      local
```

### Lab 2: Network Types Explained

#### 1. Bridge Network (Default)
```bash
docker network create my-network
docker network inspect my-network
docker run -d --name web1 --network my-network nginx
docker run -d --name web2 --network my-network nginx
docker exec web1 curl http://web2
```

#### 2. Host Network
```bash
docker run -d --name host-app --network host nginx
curl http://localhost
```

#### 3. None Network
```bash
docker run -d --name isolated-app --network none alpine sleep 3600
docker exec isolated-app ifconfig  # Only loopback
```

#### 4. Overlay Network (Swarm)
```bash
docker network create --driver overlay my-overlay
```

![Terminal Screenshot – Docker Network Types & Container Communication](./step6_networks.jpg)

### Lab 3: Network Management Commands
```bash
docker network create app-network
docker network create --driver bridge --subnet 172.20.0.0/16 --gateway 172.20.0.1 my-subnet
docker network connect app-network existing-container
docker network disconnect app-network container-name
docker network rm network-name
docker network prune
```

### Lab 4: Multi-Container Application Example
```bash
docker network create app-network

docker run -d --name postgres-db --network app-network \
  -e POSTGRES_PASSWORD=secret \
  -v pgdata:/var/lib/postgresql/data postgres:15

docker run -d --name web-app --network app-network \
  -p 8080:3000 \
  -e DATABASE_URL="postgres://postgres:secret@postgres-db:5432/mydb" \
  -e DATABASE_HOST="postgres-db" node-app
```

### Lab 5: Network Inspection & Debugging
```bash
docker network inspect bridge
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container-name
docker exec container-name nslookup another-container
docker exec container-name ping -c 4 google.com
docker exec container-name curl -I http://another-container
docker port container-name
```

### Lab 6: Port Publishing vs Exposing
```bash
docker run -d -p 80:8080 --name app1 nginx          # Host:Container
docker run -d -p 8080 --name app2 nginx              # Dynamic host port
docker run -d -p 80:80 -p 443:443 --name app3 nginx  # Multiple ports
docker run -d -p 127.0.0.1:8080:80 --name app4 nginx # Specific host IP
```

---

## Part 5: Complete Real-World Example

### Architecture: Flask + PostgreSQL + Redis
```bash
# 1. Create network
docker network create myapp-network

# 2. Start database with volume
docker run -d --name postgres --network myapp-network \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -e POSTGRES_DB=mydatabase \
  -v postgres-data:/var/lib/postgresql/data postgres:15

# 3. Start Redis
docker run -d --name redis --network myapp-network \
  -v redis-data:/data redis:7-alpine

# 4. Start Flask app with all configurations
docker run -d --name flask-app --network myapp-network \
  -p 5000:5000 -v $(pwd)/app:/app -v app-logs:/var/log/app \
  -e DATABASE_URL="postgresql://postgres:mysecretpassword@postgres:5432/mydatabase" \
  -e REDIS_URL="redis://redis:6379" \
  -e DEBUG="false" -e LOG_LEVEL="INFO" \
  --env-file .env.production flask-app:latest
```

### Monitoring the Stack
```bash
docker ps
docker stats postgres redis flask-app
docker logs -f flask-app
docker exec flask-app ping -c 2 postgres
docker exec flask-app ping -c 2 redis
docker network inspect myapp-network
```

![Terminal Screenshot – Multi-Container Real-World App (Flask + PostgreSQL + Redis)](./step7_realworld_multicontainer.jpg)

---

## Quick Reference Cheatsheet



| Category | Command | Purpose |
| :--- | :--- | :--- |
| **Volumes** | `docker volume create <name>` | Create named volume |
| | `docker run -v <vol>:/path` | Mount named volume |
| | `docker run -v /host:/container` | Bind mount |
| | `docker volume ls` | List volumes |
| | `docker volume rm <name>` | Remove volume |
| **Env Vars** | `docker run -e VAR=value` | Set variable |
| | `docker run --env-file .env` | Load from file |
| | `ENV VAR=value` (Dockerfile) | Set default |
| **Monitoring** | `docker stats` | Live metrics |
| | `docker logs -f <container>` | Follow logs |
| | `docker top <container>` | Process list |
| | `docker inspect <container>` | Full details |
| | `docker events` | Real-time events |
| **Networks** | `docker network create <name>` | Create network |
| | `docker run --network <name>` | Join network |
| | `docker network connect <net> <ctr>` | Connect container |
| | `docker network inspect <net>` | Network details |

---

## Practice Exercises

### Exercise 1: Database Backup
Create a PostgreSQL container with volume. Backup data using `docker cp` or volume backup techniques. Restore to a new container.

### Exercise 2: Multi-Service Setup
Create: web app + database + cache. Use custom network for communication. Set environment variables for configuration. Monitor all services.

### Exercise 3: Log Analysis
Run a container that generates logs. Use `docker logs` with various filters. Redirect logs to a file on host using bind mount.

### Exercise 4: Network Isolation
Create two separate networks. Put containers in different networks. Test connectivity between networks. Connect a container to both networks.

---

## Cleanup


```bash
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker volume prune -f
docker network prune -f
docker image prune -f
```

---

## Key Takeaways

1. **Volumes** persist data beyond container lifecycle.
2. **Environment variables** configure containers dynamically without rebuilding images.
3. **Monitoring commands** (`stats`, `top`, `logs`, `inspect`, `events`) help debug and optimize containers.
4. **Networks** enable secure container-to-container communication via DNS hostnames.
5. **Always use named volumes** for production data (databases, user uploads, logs).
6. **Custom bridge networks** provide better isolation and automatic DNS resolution.
7. **Monitor resource usage** to prevent OOM kills and CPU throttling.
8. **Use `.env` files** for sensitive configuration — never hardcode secrets in Dockerfiles.

---

## Result & Conclusion

### Result
- Demonstrated ephemeral container data and resolved it with Docker Volumes (anonymous, named, bind mounts).
- Configured containers dynamically using `-e` flags, `--env-file`, and Dockerfile `ENV` directives.
- Monitored containers with `docker stats`, `docker top`, `docker logs`, `docker inspect`, and `docker events`.
- Established inter-container communication using custom Docker bridge networks with DNS hostname resolution.
- Deployed a complete 3-tier application (Flask + PostgreSQL + Redis) integrating all four topics.

### Conclusion

Experiment 5 demonstrated the four pillars of production-grade Docker deployments: persistent storage (volumes), dynamic configuration (environment variables), observability (monitoring), and secure communication (networks). Mastering these concepts is critical for building reliable, scalable, and maintainable containerized applications.

---
