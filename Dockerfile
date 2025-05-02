FROM debian:bullseye-slim


# Instala dependências
RUN apt-get update && apt-get upgrade -y \
    && mkdir -p /etc/apt/keyrings \
    && apt-get install -y gnupg gosu curl ca-certificates zip unzip git supervisor libcap2-bin libpng-dev librsvg2-bin   \
    && curl -sS 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xb8dc7e53946656efbce4c1dd71daeaab4ad4cab6' | gpg --dearmor | tee /etc/apt/keyrings/ppa_ondrej_php.gpg > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu noble main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
    && apt-get update \
    && apt-get install -y php8.2-cli php8.2-dev \
       php8.2-gd php8.2-imagick \
       php8.2-imap php8.2-mysql php8.2-mbstring \
       php8.2-xml php8.2-zip php8.2-bcmath php8.2-soap \
       php8.2-intl php8.2-readline \
       php8.2-ldap \
       php8.2-msgpack php8.2-igbinary php8.2-redis \
       php8.2-memcached php8.2-pcov php8.2-xdebug \
    && apt-get update \
    && apt-get install -y mysql-client \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Cria diretório da app
WORKDIR /var/www/html

# Copia código Laravel
COPY . /var/www/html

# Copia config NGINX e script de start
COPY nginx.conf /etc/nginx/sites-available/default
COPY start-container.sh /start-container.sh
RUN chmod +x /start-container.sh

# Instala dependências PHP


# Exposição da porta padrão do nginx
EXPOSE 80

CMD ["/start-container.sh"]
