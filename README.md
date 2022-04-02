# nginx-lua-proxy
通过lua简单控制代理转发


# build 

```bash
#  docker build --pull --rm -f "Dockerfile" -t nginxluaproxy:latest "."
docker build --rm -f "Dockerfile" -t nginxluaproxy:latest "."


# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster main contrib non-free" >> /etc/apt/sources.list
echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list
echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-backports main contrib non-free" >> /etc/apt/sources.list
echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list
```
