# Dockerfile
FROM composer:latest as composer


FROM debian:bullseye-slim
# Variáveis
ENV PHP_VERSION=8.2

# Instala dependências

# Instala Composer
# Copiar o binário do Composer da imagem oficial
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Verificar a instalação
RUN composer --version



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
