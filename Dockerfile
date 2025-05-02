FROM serversideup/php:8.2-fpm-nginx

ENV PHP_OPCACHE_ENABLE=1

USER root

# Instalar a extensão SOAP para PHP
RUN install-php-extensions mcrypt soap imagick

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs nano

ARG OPENSSL_CONF=/etc/ssl/openssl.cnf

RUN echo "--- Modificando ${OPENSSL_CONF} para habilitar provedor legacy ---" && \
    # 1. Descomente 'legacy = legacy_sect' dentro da seção [provider_sect]
    #    Assume que a linha existe, comentada com '#' no início, opcionalmente com espaços.
    #    O padrão '/^\[provider_sect\]/,/^\s*\[/' limita a substituição ao bloco [provider_sect]
    sed -i -E '/^\[provider_sect\]/,/^\s*\[/s/^\s*#\s*(legacy\s*=\s*legacy_sect)/\1/' "${OPENSSL_CONF}" && \
    \
    # 2. Descomente a seção '[legacy_sect]' se estiver comentada
    sed -i -E 's/^\s*#\s*(\[legacy_sect\])/\1/' "${OPENSSL_CONF}" && \
    \
    # 3. Descomente 'activate = 1' dentro da seção [legacy_sect]
    #    Assume que a linha existe, comentada com '#'.
    #    O padrão '/^\[legacy_sect\]/,/^\s*\[/' limita a substituição ao bloco [legacy_sect]
    sed -i -E '/^\[legacy_sect\]/,/^\s*\[/s/^\s*#\s*(activate\s*=\s*1)/\1/' "${OPENSSL_CONF}" && \
    \
    echo "--- Modificação Concluída ---"

COPY --chown=www-data:www-data . /var/www/html


USER www-data

RUN npm install
RUN npm run build

RUN composer install --no-interaction --optimize-autoloader --no-dev
