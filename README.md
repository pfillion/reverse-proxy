# reverse-proxy

[![Build Status](https://drone.pfillion.com/api/badges/pfillion/reverse-proxy/status.svg?branch=master)](https://drone.pfillion.com/pfillion/reverse-proxy)
![GitHub](https://img.shields.io/github/license/pfillion/reverse-proxy)
[![GitHub last commit](https://img.shields.io/github/last-commit/pfillion/reverse-proxy?logo=github)](https://github.com/pfillion/reverse-proxy "GitHub projet")

[![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/pfillion/reverse-proxy/latest?logo=docker)](https://hub.docker.com/r/pfillion/reverse-proxy "Docker Hub Repository")
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/pfillion/reverse-proxy/latest?logo=docker)](https://hub.docker.com/r/pfillion/reverse-proxy "Docker Hub Repository")

A simple reverse-proxy under nginx for docker. It use the Let's Encrypt client and ACME library [lego](https://github.com/go-acme/lego) written in Go for creation of certificates. More, you can setup cron job to renew certificates for all your site behind your reverse-proxy.

## Versions

* [latest](https://github.com/pfillion/reverse-proxy/tree/master) available as ```pfillion/reverse-proxy:latest``` at [Docker Hub](https://hub.docker.com/r/pfillion/reverse-proxy/)

## Tools included in the docker image

* lego
* libressl
* nginx-mod-stream

## Environnement variables

The reverse-proxy support one environnement variables.

```LEGO_MODE``` definde how ```lego``` will interact with Let's Encrypt for ACME challenge. The value possible is ```staging``` (default) and ```normal```. For testing, it recommender to use the staging api.

## Configuration file

You can mount directly a file or use docker configuration to schedule all job like a crontab file. See the example below.

* /configs/config.json

```json
[
    {
        "schedule": "0 0 0 */2 *",
        "command": "lego.sh",
        "args": [
            "www.example.com",
            "example@example.com"
        ]
    },
    {
        "schedule": "0 0 0 */2 *",
        "command": "lego.sh",
        "args": [
            "another.example.com",
            "example@example.com"
        ]
    },
    ...
]
```

This config will schedule cron job for renew certificate and copy them in the ```/.lego``` folder by default. All yopu have to do is configure you nginx proxy to use them.

* /etc/nginx/nginx.conf

```conf
server {
    listen 443 ssl;
    http2 on; 
    server_name www.example.com;
    ssl_certificate /.lego/certificates/www.example.com.crt; 
    ssl_certificate_key  /.lego/certificates/www.example.com.key;
    ... 
}
```

## Docker compose

See the docker swarm in the source code or below.

```yml
version: '3.7'

services:
  nginx-proxy:
    image: pfillion/reverse-proxy:latest
    environment:
      LEGO_MODE: 'staging'
    networks:
      - reverse_proxy_network
    ports:
      - 80:80
      - 443:443
    volumes:
      - nginx_volume:/etc/nginx
      - cron_configs_volume:/configs

networks:
  reverse_proxy_network:
    driver: overlay

volumes:
  nginx_volume:
    ...
  cron_configs_volume:
    ...
```

## Authors

* [pfillion](https://github.com/pfillion)

## License

MIT
