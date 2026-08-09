FROM alpine:3.20 AS builder

ENV NGINX_VERSION=1.25.1 \ 
    LUA_MODULE_VERSION=0.10.25 \ 
    LUA_RESTY_CORE_VERSION=0.1.27 \ 
    LUA_RESTY_LRUCACHE_VERSION=0.13 \ 
    NGINX_DEVEL_KIT_VERSION=0.3.2 \ 
    LUAJIT_VERSION=2.1-20230410 \ 
    LUA_VERSION=5.1 \ 
    LUA_PATH="/usr/local/lib/lua/5.1/?.lua;;" \
    BUILD_DEPS=" \
            build-base ca-certificates patch cmake \
            autoconf automake curl luajit-dev libtool \
            git gcc libc-dev make openssl-dev pcre-dev \
            zlib-dev linux-headers libxslt-dev gd-dev \
            perl-dev libedit-dev mercurial \
            bash alpine-sdk findutils gnupg" \
    NGINX_SETUP_DIR=/usr/src/nginx  \
    NGINX_CACHE_DIR=/var/cache/nginx  \
    NGINX_LOG_DIR=/var/log/nginx  \
    NGINX_CONF_DIR=/etc/nginx  \
    NGINX_MODULES=""
RUN set -x \
    && mkdir -p \
    ${NGINX_SETUP_DIR} \
    ${NGINX_CACHE_DIR} \
    ${NGINX_LOG_DIR} \
    ${NGINX_CONF_DIR} \
    && apk add --no-cache --virtual .build-deps ${BUILD_DEPS} \
    && \
    echo "${NGINX_MODULES}" \
    && \
    NGINX_MODULES="${NGINX_MODULES} --add-module=${NGINX_SETUP_DIR}/ngx_devel_kit-${NGINX_DEVEL_KIT_VERSION}"; \
    curl -fSL https://github.com/simpl/ngx_devel_kit/archive/v${NGINX_DEVEL_KIT_VERSION}.tar.gz -o "${NGINX_SETUP_DIR}/ngx_devel_kit.tar"; \
    tar -zxC  "${NGINX_SETUP_DIR}" -f "${NGINX_SETUP_DIR}/ngx_devel_kit.tar"; \
    curl -fSL https://github.com/openresty/luajit2/archive/v${LUAJIT_VERSION}.tar.gz -o /tmp/luajit2-module.tar.gz; \
    tar -zxC /tmp/ -f /tmp/luajit2-module.tar.gz; \
    cd /tmp/luajit2-${LUAJIT_VERSION} && make && make install; \
    curl -fSL https://github.com/openresty/lua-resty-core/archive/v${LUA_RESTY_CORE_VERSION}.tar.gz -o /tmp/lua-resty-core.tar.gz; \
    curl -fSL https://github.com/openresty/lua-resty-lrucache/archive/v${LUA_RESTY_LRUCACHE_VERSION}.tar.gz -o /tmp/lua-resty-lrucache.tar.gz;\
    tar -zxC /tmp/ -f /tmp/lua-resty-core.tar.gz; \
    tar -zxC /tmp/ -f /tmp/lua-resty-lrucache.tar.gz; \
    cd /tmp/lua-resty-core-${LUA_RESTY_CORE_VERSION} ; make install ; cd - ;\
    cd /tmp/lua-resty-lrucache-${LUA_RESTY_LRUCACHE_VERSION} ; make install  ; cd - ;\
    NGINX_MODULES="${NGINX_MODULES} --add-module=${NGINX_SETUP_DIR}/lua-nginx-module-${LUA_MODULE_VERSION}"; \
    curl -fSL https://github.com/openresty/lua-nginx-module/archive/v${LUA_MODULE_VERSION}.tar.gz -o "${NGINX_SETUP_DIR}/lua_module.tar"; \
    tar -zxC "${NGINX_SETUP_DIR}" -f "${NGINX_SETUP_DIR}/lua_module.tar"; \
    export LUAJIT_LIB=/usr/local/lib; \
    export LUAJIT_INC=/usr/local/include/luajit-2.1; \
    BASE_CONFIGURE_ARGS="\
        --conf-path=${NGINX_CONF_DIR}/nginx.conf \
        --error-log-path=${NGINX_LOG_DIR}/error.log \
        --group=nginx \
        --http-client-body-temp-path=${NGINX_CACHE_DIR}/client_temp \
        --http-fastcgi-temp-path=${NGINX_CACHE_DIR}/fastcgi_temp \
        --http-log-path=${NGINX_LOG_DIR}/access.log \
        --http-proxy-temp-path=${NGINX_CACHE_DIR}/proxy_temp \
        --http-scgi-temp-path=${NGINX_CACHE_DIR}/scgi_temp \
        --http-uwsgi-temp-path=${NGINX_CACHE_DIR}/uwsgi_temp \
        --lock-path=/var/run/nginx.lock \
        --modules-path=/usr/lib/nginx/modules \
        --pid-path=/var/run/nginx.pid \
        --prefix=${NGINX_CONF_DIR} \
        --sbin-path=/usr/sbin/nginx \
        --user=nginx \
        --with-compat \
        --with-file-aio \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_degradation_module \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-ld-opt=-Wl,--as-needed \
        --with-ld-opt=-Wl,-rpath,$LUAJIT_LIB \
        --with-mail \
        --with-mail_ssl_module \
        --with-perl_modules_path=/usr/lib/perl5/vendor_perl \
        --with-stream \
        --with-stream_realip_module \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-threads \
        --with-http_image_filter_module=dynamic \
        --with-http_xslt_module=dynamic \
        ${NGINX_MODULES} \
        " \
    && curl -fSL http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o "${NGINX_SETUP_DIR}/nginx.tar.gz" \
    && tar -zxC "${NGINX_SETUP_DIR}" -f "${NGINX_SETUP_DIR}/nginx.tar.gz" \
    && rm ${NGINX_SETUP_DIR}/nginx.tar.gz \
    && cd ${NGINX_SETUP_DIR}/nginx-${NGINX_VERSION} \
    && ls -lah /usr/src/nginx/ \
    && ./configure $BASE_CONFIGURE_ARGS --with-cc-opt='-Os -fomit-frame-pointer'  --with-debug \
    && ls -lah objs/ \
    && make \
    && make install \
    && rm -rf ${NGINX_CONF_DIR}/html/ \
    && mkdir ${NGINX_CONF_DIR}/conf.d/ \
    && mkdir -p /usr/share/nginx/html/ \
    && install -m644 html/index.html /usr/share/nginx/html/ \
    && install -m644 html/50x.html /usr/share/nginx/html/ \
    && ln -s /usr/lib/nginx/modules ${NGINX_CONF_DIR}/modules \
    && strip  -v /usr/sbin/nginx* \
    && strip  -v /usr/lib/nginx/modules/*.so \
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    && runDeps="$(scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }')" \
    && apk add --no-cache $runDeps \
    && apk add --no-cache tzdata libgcc \
    && <<EOF cat > /etc/nginx/nginx.conf
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                     '\$status \$body_bytes_sent "\$http_referer" '
                     '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;
    error_log /dev/stdout debug;

    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       80;
        server_name  localhost;
        default_type text/plain;
        log_subrequest on;
        location /test {
            set \$a \$arg_a;
            rewrite_by_lua_block {
                local res = ngx.location.capture('/attr/',
                    { args = { a = ngx.var.a } }
                )
                if res.body == "1" then
                    return ngx.exec('@golocation_1')
                elseif res.body == "2" then
                    return ngx.exec('@golocation_2')
                end
            }
            alias /index;
        }
        location @golocation_1 {
            content_by_lua_block {
                ngx.say("You are in golocation_1")
            }
        }
        location @golocation_2 {
            content_by_lua_block {
                ngx.say("You are in golocation_2")
            }
        }
        location /attr/ {
            add_header "attr" \$arg_a;
            return 200 "\$arg_a"; 
        }
    }
}
EOF

FROM alpine:3.20

ENV LUAJIT_VERSION=2.1-20230410 \ 
    LUA_VERSION=5.1 \ 
    LUA_PATH="/usr/local/lib/lua/5.1/?.lua;;" 


COPY --from=builder /usr /usr
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /var/cache/nginx /var/cache/nginx

RUN addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apk add --no-cache pcre zlib openssl ca-certificates tzdata libgcc \
    && mkdir -p /index /var/log/nginx && echo "I am index.html" > /index/index.html && chown -R nginx.nginx /index \
    && ln -s /usr/lib/nginx/modules /etc/nginx/modules \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log 


EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
