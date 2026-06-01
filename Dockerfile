FROM alpine:3.20

# Instalar PHP 8.3 i les extensions necessàries de Laravel directament des de paquets precompilats
RUN apk add --no-cache \
    php83 \
    php83-cli \
    php83-common \
    php83-composer \
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
    php83-fileinfo

# Crear un enllaç simbòlic perquè el comando 'php' apunti a 'php83'
RUN ln -sf /usr/bin/php83 /usr/bin/php

# Configurar el directori de treball
WORKDIR /app

# Copiar el codi del projecte
COPY . /app

# Instalar dependències de Composer (saltant-nos els scripts problemàtics)
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

# Exposar el port de Railway
EXPOSE 80

# Arrencar el servidor integrat de Laravel
CMD ["sh", "-c", "php artisan package:discover --ansi && php artisan serve --host=0.0.0.0 --port=80"]