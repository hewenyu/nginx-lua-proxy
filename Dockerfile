# 安装参考基于 at http://wiki.nginx.org/HttpLuaModule#Installation
FROM debian:buster

ENV VER_NGINX_DEVEL_KIT=0.3.1
ENV VER_LUA_NGINX_MODULE=0.10.20
ENV VER_NGINX=1.19.3
ENV VER_LUAJIT=2.0.5

ENV NGINX_DEVEL_KIT ngx_devel_kit-${VER_NGINX_DEVEL_KIT}
ENV LUA_NGINX_MODULE lua-nginx-module-${VER_LUA_NGINX_MODULE}
ENV NGINX_ROOT=/nginx
ENV WEB_DIR ${NGINX_ROOT}/html

# openresty modules
ENV VER_LUA_RESTY_REDIS=0.29
ENV LUA_RESTY_REDIS lua-resty-redis-${VER_LUA_RESTY_REDIS}



ENV LUAJIT_LIB /usr/local/lib
ENV LUAJIT_INC /usr/local/include/luajit-2.0


# 修改清华源
# ADD sources.list /etc/apt/sources.list

RUN apt-get update
RUN apt-get install supervisor curl -y

# 安装 轻量级 DNS 解析, 基于/etc/hosts实现正确的nginx名称解析
RUN apt-get install -y  dnsmasq
# docker中的dnsmasq，它必须以用户root身份运行:
RUN sed -i 's/#user=/user=root/g' /etc/dnsmasq.conf

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ***** 安装依赖 *****

# 普通依赖
RUN apt-get -qq -y install make gcc
# Nginx 依赖
RUN apt-get -qq -y install libpcre3 libpcre3-dev zlib1g-dev libssl-dev

# ***** 下载文件包 *****

# Download modules
RUN curl http://nginx.org/download/nginx-${VER_NGINX}.tar.gz -o nginx-${VER_NGINX}.tar.gz
RUN curl http://luajit.org/download/LuaJIT-${VER_LUAJIT}.tar.gz -o LuaJIT-${VER_LUAJIT}.tar.gz
# https://codeload.github.com/vision5/ngx_devel_kit/tar.gz/refs/tags/v0.3.1
RUN curl https://codeload.github.com/vision5/ngx_devel_kit/tar.gz/refs/tags/v${VER_NGINX_DEVEL_KIT} -o ${NGINX_DEVEL_KIT}.tar.gz
RUN curl https://codeload.github.com/openresty/lua-nginx-module/tar.gz/refs/tags/v${VER_LUA_NGINX_MODULE} -o ${LUA_NGINX_MODULE}.tar.gz


# Download openresty libs
# https://codeload.github.com/openresty/lua-resty-redis/tar.gz/refs/tags/v0.30rc1
RUN curl https://codeload.github.com/openresty/lua-resty-redis/tar.gz/refs/tags/v${VER_LUA_RESTY_REDIS} -o ${LUA_RESTY_REDIS}.tar.gz

# Untar
RUN tar -zxvf nginx-${VER_NGINX}.tar.gz && rm nginx-${VER_NGINX}.tar.gz
RUN tar -zxvf LuaJIT-${VER_LUAJIT}.tar.gz && rm LuaJIT-${VER_LUAJIT}.tar.gz
RUN tar -zxvf ${NGINX_DEVEL_KIT}.tar.gz && rm ${NGINX_DEVEL_KIT}.tar.gz
RUN tar -zxvf ${LUA_NGINX_MODULE}.tar.gz && rm ${LUA_NGINX_MODULE}.tar.gz

#Lua LIBS
RUN tar -xzvf ${LUA_RESTY_REDIS}.tar.gz && rm ${LUA_RESTY_REDIS}.tar.gz

# copy openresty libraries to LUAJIT_LIB
RUN cp -r ${LUA_RESTY_REDIS}/lib ${LUAJIT_LIB}/lua-libs


# ***** BUILD FROM SOURCE *****

# LuaJIT
WORKDIR /LuaJIT-${VER_LUAJIT}
RUN make
RUN make install

# Nginx with LuaJIT
WORKDIR /nginx-${VER_NGINX}
RUN ./configure --prefix=${NGINX_ROOT} --with-ld-opt="-Wl,-rpath,${LUAJIT_LIB}" --add-module=/${NGINX_DEVEL_KIT} --add-module=/${LUA_NGINX_MODULE}
RUN make -j2
RUN make install
RUN ln -s ${NGINX_ROOT}/sbin/nginx /usr/local/sbin/nginx

# ***** MISC *****
WORKDIR ${WEB_DIR}
EXPOSE 80
EXPOSE 443

# ***** CLEANUP *****
RUN rm -rf /nginx-${VER_NGINX}
RUN rm -rf /LuaJIT-${VER_LUAJIT}
RUN rm -rf /${NGINX_DEVEL_KIT}
RUN rm -rf /${LUA_NGINX_MODULE}
# TODO: Uninstall build only dependencies?
# TODO: Remove env vars used only for build?

COPY nginx.conf /nginx/conf/nginx.conf
COPY nginx-lua.conf /nginx/conf/nginx-lua.conf

# Run nginx and dnsmasq under supervisor
CMD ["/usr/bin/supervisord"]
