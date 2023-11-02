#!/bin/bash



# Specify the Nginx configuration file path

nginx_conf=${PATH_TO_CONFIG_FILE}



# Increase worker processes and connections

sed -i 's/worker_processes.*/worker_processes auto;/' "$nginx_conf"

sed -i 's/worker_connections.*/worker_connections 1024;/' "$nginx_conf"



# Enable gzip compression

sed -i '/gzip on;/a \    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;' "$nginx_conf"



# Configure client-side caching

cat <<EOL >> "$nginx_conf"

location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {

    expires 7d;

    add_header Cache-Control "public, max-age=604800, immutable";

}

EOL



# Enable proxy buffering

sed -i '/http {/a \    proxy_buffering on;' "$nginx_conf"

sed -i '/proxy_buffering on;/a \    proxy_buffer_size 8k;' "$nginx_conf"

sed -i '/proxy_buffer_size 8k;/a \    proxy_buffers 8 8k;' "$nginx_conf"



# Add FastCGI caching (modify paths and cache settings)

cat <<EOL >> "$nginx_conf"

fastcgi_cache_path /path/to/cache levels=1:2 keys_zone=my_cache:10m;

server {

    location / {

        fastcgi_cache my_cache;

        fastcgi_cache_valid 200 1h;

        fastcgi_cache_key "\$scheme\$request_method\$host\$request_uri";

        ...

    }

}

EOL



# Add proxy caching (modify paths and cache settings)

cat <<EOL >> "$nginx_conf"

proxy_cache_path /path/to/cache levels=1:2 keys_zone=my_cache:10m;

server {

    location / {

        proxy_cache my_cache;

        proxy_cache_valid 200 1h;

        proxy_cache_key "\$scheme\$request_method\$host\$request_uri";

        ...

    }

}

EOL



# Configure keep-alive connections

sed -i 's/keepalive_timeout.*/keepalive_timeout 65;/' "$nginx_conf"

sed -i '/keepalive_timeout 65;/a \    keepalive_requests 100;' "$nginx_conf"



# Reload Nginx to apply changes

service nginx reload