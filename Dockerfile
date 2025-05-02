FROM serversideup/php:8.2-fpm-nginx

ENV PHP_OPCACHE_ENABLE=1

USER root

# Instalar a extensão SOAP para PHP
RUN install-php-extensions mcrypt soap

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

COPY --chown=www-data:www-data . /var/www/html


USER www-data

RUN npm install
RUN npm run build

RUN composer install --no-interaction --optimize-autoloader --no-dev
