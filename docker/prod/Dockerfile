### Etapa 1: Build dos assets com Node.js ###
FROM node:18-alpine AS node-builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY resources/ ./resources
COPY vite.config.js ./
RUN npm run build


### Etapa 2: PHP + Composer ###
FROM php:8.2-fpm-alpine AS app

# Instala dependências do sistema e PHP extensions
RUN apk add --no-cache \
        nginx \
        curl \
        zip \
        unzip \
        libzip-dev \
        oniguruma-dev \
        autoconf \
        g++ \
        make \
        bash \
        icu-dev \
        zlib-dev \
        libxml2-dev \
        sqlite-libs \
        git \
        nodejs \
        npm \
    && docker-php-ext-install \
        pdo pdo_mysql mbstring zip intl soap xml \
    && rm -rf /var/cache/apk/*

# Instala Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copia arquivos da aplicação
COPY . .

# Instala dependências PHP
RUN composer install --no-dev --optimize-autoloader --prefer-dist

# Copia assets compilados do estágio anterior
COPY --from=node-builder /app/public/build ./public/build

# Permissões e caches do Laravel
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]
