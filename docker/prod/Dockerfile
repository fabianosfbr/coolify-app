FROM php:8.2-fpm

USER root

# Instala o Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# Instala o Node.js
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
    RUN apt-get install -y nodejs nano
    

# Instala dependências do sistema e extensões do PHP
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    zip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libssl-dev \
    libmagickwand-dev \
    libxslt-dev \
    curl \
    supervisor \
    && docker-php-ext-configure zip \
    && docker-php-ext-configure intl \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        zip \
        soap \
        intl \
        xsl \
        opcache \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
    

# Define diretório de trabalho
WORKDIR /var/www

# Copia arquivos da aplicação (ex: Laravel)
COPY . .

# Permissões para diretórios necessários
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage /var/www/bootstrap/cache


# Habilita opcache com bom desempenho para Laravel
RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
 && echo "opcache.enable_cli=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
 && echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
 && echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
 && echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
 && echo "opcache.validate_timestamps=0" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini


# Copia o arquivo de configuração do supervisor


# Usuário padrão para execução
USER www-data

RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist
RUN npm install
RUN npm run build


# Comando para iniciar o supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
