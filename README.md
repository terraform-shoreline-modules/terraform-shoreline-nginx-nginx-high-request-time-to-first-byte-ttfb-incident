
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# High Nginx Request Time to First Byte (TTFB) Incident.
---

This incident type refers to a situation where the time taken by Nginx server to send the first byte of the response to the client is high. This results in a slow loading website or application. It could be caused by various factors such as network latency, server overload, improper configuration, or other issues with the server. This incident type requires immediate attention to reduce the TTFB and improve the overall website or application performance.

### Parameters
```shell
export SERVER_IP="PLACEHOLDER"

export URL="PLACEHOLDER"

export PATH_TO_CONFIG_FILE="PLACEHOLDER"
```

## Debug

### Check the Nginx status
```shell
systemctl status nginx
```

### Check the Nginx error log for any errors
```shell
tail -f /var/log/nginx/error.log
```

### Check the Nginx access log for the request processing time
```shell
tail -f /var/log/nginx/access.log | awk '{print $1,$4,$7,$8}'
```

### Check the network latency between the client and server
```shell
traceroute ${SERVER_IP}
```

### Check the server CPU and memory usage
```shell
top
```

### Check the disk usage on the server
```shell
df -h
```

### Check the network usage on the server
```shell
iftop
```

### Check the server DNS resolution
```shell
nslookup ${SERVER_IP}
```

### Check server response time for a specific URL
```shell
curl -w "Total time: %{time_total}\n" -o /dev/null -s ${URL}
```

## Repair

### Review and make changes to the Nginx configuration file to ensure it is optimized for performance.
```shell
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


```