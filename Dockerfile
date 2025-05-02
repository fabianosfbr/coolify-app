FROM serversideup/php:8.2-fpm-nginx

ENV PHP_OPCACHE_ENABLE=1

USER root

# Instalar a extensão SOAP para PHP
RUN install-php-extensions mcrypt soap imagick

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs nano

ARG OPENSSL_CONF=/etc/ssl/openssl.cnf
RUN echo "--- Modificando ${OPENSSL_CONF} ---" && \
    \
    # 1. Descomente a linha 'providers = provider_sect'
    #    Procura por '# providers = provider_sect' (com espaços opcionais) e remove o '#' inicial
    sed -i -E 's/^\s*#\s*(providers\s*=\s*provider_sect)/\1/' "${OPENSSL_CONF}" && \
    \
    # 2. Descomente a seção '[default_sect]'
    #    Procura por '# [default_sect]' (com espaços opcionais) e remove o '#' inicial
    #    Escapa os colchetes '[' e ']' pois são caracteres especiais no regex
    sed -i -E 's/^\s*#\s*(\[default_sect\])/\1/' "${OPENSSL_CONF}" && \
    \
    # 3. Descomente 'activate = 1' DENTRO da seção [default_sect]
    #    Aplica a substituição apenas entre a linha '[default_sect]' e a próxima seção '[...'
    sed -i -E '/^\[default_sect\]/,/^\s*\[/s/^\s*#\s*(activate\s*=\s*1)/\1/' "${OPENSSL_CONF}" && \
    \
    # 4. Adicione a seção [legacy_sect] com activate = 1 ao final do arquivo
    #    O '$a\' diz ao sed para anexar o texto seguinte após a última linha do arquivo.
    #    \n é usado para criar uma nova linha entre '[legacy_sect]' e 'activate = 1'.
    #    Escapa os colchetes '[' e ']'.
    sed -i -E '$a\\n[legacy_sect]\nactivate = 1' "${OPENSSL_CONF}" && \
    \
    echo "--- Modificação Concluída ---"

# (Opcional mas recomendado) Verifique a versão do OpenSSL e os provedores carregados
# Isto roda durante o processo de build
RUN echo "--- Verificando Configuração e Provedores OpenSSL ---" && \
    echo "Conteúdo relevante de ${OPENSSL_CONF}:" && \
    grep -E "providers =|\[default_sect\]|\[legacy_sect\]|activate =" "${OPENSSL_CONF}" && \
    echo "---" && \
    openssl version && \
    openssl list -providers ; \
    echo "---------------------------------"

COPY --chown=www-data:www-data . /var/www/html


USER www-data

RUN npm install
RUN npm run build

RUN composer install --no-interaction --optimize-autoloader --no-dev
