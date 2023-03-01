#!/bin/sh
/usr/bin/certbot renew --quiet --post-hook "/usr/sbin/nginx -s reload"