# Dockerfile

FROM debian:bullseye-slim

# Variáveis
ENV PHP_VERSION=8.2

# Instala dependências
RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    zip \
    unzip \
    git \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-pgsql \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-tokenizer \
    php${PHP_VERSION}-fileinfo \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-readline \
    php${PHP_VERSION}-common \
    supervisor && \
    apt-get clean

# Instala Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Cria diretório da app
WORKDIR /var/www/html

# Copia código Laravel
COPY . /var/www/html

# Copia config NGINX e script de start
COPY nginx.conf /etc/nginx/sites-available/default
COPY start-container.sh /start-container.sh
RUN chmod +x /start-container.sh

# Instala dependências PHP
RUN composer install --no-dev --optimize-autoloader \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Exposição da porta padrão do nginx
EXPOSE 80

CMD ["/start-container.sh"]
