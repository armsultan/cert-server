FROM nginx:alpine-slim

ADD default.conf /etc/nginx/conf.d/default.conf
ADD crontab.txt /crontab.txt
ADD cert-cron.sh /cert-cron.sh
ADD create-cert.sh /create-cert.sh

RUN apk add python3 python3-dev py3-pip build-base libressl-dev musl-dev libffi-dev rust cargo nano \
    && pip3 install pip --upgrade \
    && pip3 install certbot-dns-cloudflare \
    && chmod +x /*.sh \
    && crontab /crontab.txt \
    && mkdir -p /var/log/letsencrypt \
    && touch /var/log/letsencrypt/letsencrypt.log \
    # Check imported NGINX config
    && nginx -t \
    # Forward request logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    # && ln -sf /dev/stderr /var/log/nginx/error.log \
    # Forward letsencrypt logs to docker log collector
    && ln -sf /dev/stderr /var/log/letsencrypt/letsencrypt.log 

EXPOSE 9000