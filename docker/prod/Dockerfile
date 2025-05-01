FROM php:8.2-fpm-alpine

LABEL maintainer="Coolify App"

WORKDIR /var/www/html

# Install dependencies
RUN apk add --no-cache \
    curl \
    zip \
    unzip \
    git \
    supervisor \
    libpng-dev \
    libzip-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    oniguruma-dev \
    icu-dev \
    mysql-client

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    mysqli \
    mbstring \
    zip \
    exif \
    pcntl \
    bcmath \
    gd \
    intl \
    opcache

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configure PHP
COPY docker/prod/php.ini /usr/local/etc/php/conf.d/app.ini

# Configure Supervisor
RUN mkdir -p /var/log/supervisor
COPY docker/prod/supervisor.conf /etc/supervisor/conf.d/supervisord.conf

# Copy application files
COPY . /var/www/html

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Install application dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

# Generate application key (apenas se não existir)
RUN if [ ! -f .env ]; then \
    cp .env.example .env; \
    php artisan key:generate --force; \
fi

# Build frontend assets (se necessário)
# RUN npm ci && npm run build

# Expose port 9000 (PHP-FPM)
EXPOSE 9000

# Iniciar PHP-FPM e Supervisor
CMD ["/bin/sh", "-c", "php-fpm -D && exec supervisord -c /etc/supervisor/conf.d/supervisord.conf"]
