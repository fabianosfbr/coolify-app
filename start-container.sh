#!/bin/bash

# Inicia o PHP-FPM
service php8.3-fpm start

# Inicia o NGINX
nginx -g "daemon off;"
