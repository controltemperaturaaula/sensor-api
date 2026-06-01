FROM alpine:3.20

# Instalar PHP 8.3 i les extensions necessàries
RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/v3.20/community \
    php83 \
    php83-cli \
    php83-common \
    php83-mbstring \
    php83-xml \
    php83-openssl \
    php83-pdo \
    php83-pdo_mysql \
    php83-tokenizer \
    php83-ctype \
    php83-session \
    php83-dom \
    php83-xmlwriter \
    php83-fileinfo \
    composer

# Crear l'enllaç simbòlic perquè 'php' apunti a 'php83'
RUN ln -sf /usr/bin/php83 /usr/bin/php

# Configurar el directori de treball
WORKDIR /app

# Copiar el codi del projecte
COPY . /app

# Instalar dependències de Composer (saltant scripts al build)
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

# Exposar el port de Railway
EXPOSE 80

# Comando d'arrencada amb el servidor natiu de PHP apuntant a la carpeta public de Laravel
CMD ["sh", "-c", "php artisan package:discover --ansi && php -S 0.0.0.0:80 -t public"]