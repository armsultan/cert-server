#!/bin/sh
certbot certonly \
    --non-interactive \
    --agree-tos \
    --email ${email} \
    --dns-cloudflare \
    --dns-cloudflare-credentials /run/secrets/cloudflare_credentials \
    --domains  "*.example.com" 


certbot certonly \
    --non-interactive \
    --agree-tos \
    --email ${email} \
    --dns-cloudflare \
    --dns-cloudflare-credentials /run/secrets/cloudflare_credentials \
    --domains "*.example.org"