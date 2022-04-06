FROM openresty/openresty:1.19.9.1-10-buster

# 必备
RUN apt-get update
RUN apt-get install supervisor curl  -y

# # 安装 轻量级 DNS 解析, 基于/etc/hosts实现正确的nginx名称解析
RUN apt-get install -y  dnsmasq
# # docker中的dnsmasq，它必须以用户root身份运行:
RUN sed -i 's/#user=/user=root/g' /etc/dnsmasq.conf

EXPOSE 80
EXPOSE 443


# 复制配置文件
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY nginx-lua.conf /usr/local/openresty/nginx/conf/nginx-lua.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# # Run nginx and dnsmasq under supervisor
CMD ["/usr/bin/supervisord"]
