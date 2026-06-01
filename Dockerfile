FROM dunglas/frankenphp:1-php8.4

# 1. Instalar el comando unzip del sistema (necessari per a Composer)
RUN apt-get update && apt-get install -y unzip && apt-get clean

# 2. Instalar extensions de PHP exigides per Laravel 13
RUN install-php-extensions \
    pcntl \
    pdo_mysql \
    mbstring \
    xml \
    openssl \
    tokenizer \
    ctype \
    fileinfo \
    zip

# 3. Instalar Composer globalment
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 4. Configurar directori de treball i copiar el projecte
WORKDIR /app
COPY . /app

# 5. Crear estructures de carpetes i permisos reals de Laravel
RUN mkdir -p /app/storage/framework/cache/data \
    && mkdir -p /app/storage/framework/sessions \
    && mkdir -p /app/storage/framework/views \
    && mkdir -p /app/storage/logs \
    && mkdir -p /app/bootstrap/cache \
    && chmod -R 777 /app/storage /app/bootstrap/cache

# 6. Instalar dependències de Composer de producció
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts

# 7. Crear el fitxer de salut estàtic de contingència
RUN echo '<?php echo "OK";' > /app/public/health.php

# Forçar que FrankenPHP escolti en HTTP pur utilitzant el port que Railway demana
ENV SERVER_NAME="http://:8080"
ENV FRANKENPHP_HTTP_PORT=8080

EXPOSE 8080

# Arrencada directa indicant la carpeta pública
CMD ["frankenphp", "php-server", "--listen", ":8080", "--public-dir", "public/"]