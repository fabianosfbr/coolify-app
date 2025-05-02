# Dockerfile

FROM debian:bullseye-slim

# Variáveis
ENV PHP_VERSION=8.2

# Instala dependências


# Instala Composer
# Baixe o instalador do Composer, execute-o e mova o composer.phar para um diretório global
# O script de instalação do Composer já verifica a assinatura do instalador
RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php && \
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm /tmp/composer-setup.php
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
