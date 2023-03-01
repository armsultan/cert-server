# NGINX + Certbot + Cloudflare DNS

A hacky homelab solution. A simple implementation for a "central certificate
server" to renew Let's Encrypt certs and share them easily with servers in your
infrastructure.

Using [Cron](https://crontab.guru/), [Certbot](https://certbot.eff.org/) with
the [Cloudflare DNS
plugin](https://certbot-dns-cloudflare.readthedocs.io/en/stable/) keep your
certificates updated. Then [NGINX]()https://nginx.org/ serves these Let's
Encrypt certs (`.pem` files) over `port 9000`.

Access control can be enforced using NGINX [API key
Authentication](https://www.nginx.com/blog/deploying-nginx-plus-as-an-api-gateway-part-1/#implement-auth)
and [IP
allowlisting](https://nginx.org/en/docs/http/ngx_http_access_module.html) if
desired.

Note: [read this
issue](https://github.com/nginx-proxy/nginx-proxy/issues/133#issuecomment-754094932)
if you are having trouble getting the real client IP

```shell                                                                             
                                               Host                                                         
                 +---------------------------------+                                                        
                 |              Container          |                                                        
                 |   +--------------------+        |                                                        
                 |   |     NGINX          |        |                                                        
-----------------|----     +              |        |                                                        
 port 9000       |   |     Certbot        |        |                                                        
                 |   |                    |        |                                                        
                 |   |        |           |        |                                                        
                 |   +--------|-----------+        |                                                        
                 |            |                    |                                                        
                 |            |bind mount          |                                                        
                 |   +-------------------+         |                                                        
                 |   |  ./letsencrypt    |         |                                                        
                 |   |                   |         |                                                        
                 |   |                   |         |                                                        
                 |   +-------------------+         |                                                        
                 |                                 |                                                        
                 +---------------------------------+                                                                                                   
                                                                                           
````

## Setup

1. Replace `${email}` and `${api_key}` in [`cloudflare.ini`](cloudflare.ini)
   credentials file. It is recommended to use an API Token no Global API Key.
   ([Read about configuring
   Credentials](https://certbot-dns-cloudflare.readthedocs.io/en/stable/#credentials))

1. Replace `${email}` and the domain placeholders in [`create-cert.sh`](create-cert.sh) with
   your own domain(s) and/or wildcard domain(s). This script will run on the
   first time you start the container

1. A cronjob will run periodicly to renew the cert and restart NGINX. You can
   edit the [`cron`](crontab.txt) job interval or any options such as `--post-hook`

## Usage

1. Start container using `docker-compose`

    ```bash
    # Rebuild container if you make changes
    docker-compose build --no-cache

    # Start the container
    docker-compose up -d
    
    # Tail the logs
    docker-compose logs -f
    ```

1. You can retrieve the certs over `port 9000` 

    ```bash
    # Examples

    # NGINX will serve /etc/letsencrypt/live/example.com/fullchain.pem from disk
    curl http://localhost:9000/example.com/fullchain.pem
    # This gets the private key for example.org
    curl http://localhost:9000/example.org/privkey.pem
    ```

1. You can also retrieve the certs from the mounted folder
   `./letsencrypt/live/${domain}/*.pem`