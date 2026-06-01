FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalar PHP 8.3 i les extensions essencials
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    unzip \
    git \
    && add-apt-repository ppa:ondrej/php -y \
    && apt-get update && apt-get install -y \
    php8.3-cli \
    php8.3-common \
    php8.3-mbstring \
    php8.3-xml \
    php8.3-mysql \
    php8.3-tokenizer \
    php8.3-curl \
    php8.3-zip \
    && apt-get clean

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /app
COPY . /app

# Crear carpetes estructurals i permisos de Laravel
RUN mkdir -p /app/storage/framework/cache/data \
    && mkdir -p /app/storage/framework/sessions \
    && mkdir -p /app/storage/framework/views \
    && mkdir -p /app/storage/logs \
    && mkdir -p /app/bootstrap/cache \
    && chmod -R 777 /app/storage /app/bootstrap/cache

# Instalar dependències
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

# CREAR FITXER DE SALUT DIRECTAMENT A LA CARPETA PUBLIC
RUN echo '<?php echo "OK";' > /app/public/health.php

EXPOSE $PORT

# ARRENCADA EXPLICITA: Entrem a la carpeta 'public' i aixequem el servidor des d'allà dins
CMD ["sh", "-c", "php /app/artisan package:discover --ansi || true && cd /app/public && php -S 0.0.0.0:$PORT"]