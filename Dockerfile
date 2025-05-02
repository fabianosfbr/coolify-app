FROM debian:bullseye-slim


# Instala dependências



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
