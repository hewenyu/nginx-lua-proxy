# nginx-lua-proxy
通过lua简单控制代理转发


## docker-compose

```bash
version: '3'
services:
  proxy:
    image: hewenyulucky/nginx-lua-proxy
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - nsqlookupd
    restart: always
  redis:
    image: redis
    ports:
      - "6379:6379"
    restart: always

```

## USE 

```bash
# Add to redis some hosts

redis-cli rpush frontend:dynamic1.example.com mywebsite
redis-cli rpush frontend:dynamic1.example.com http://192.168.0.50:80

redis-cli rpush frontend:dynamic2.example.com mywebsite
redis-cli rpush frontend:dynamic2.example.com http://192.168.0.100:80


# Check if everything is working
curl -H 'Host: dynamic1.example.com' http://localhost:9090
# or
curl -H 'Host: dynamic2.example.com' http://localhost:9090
```