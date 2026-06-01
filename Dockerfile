FROM dunglas/frankenphp:1-php8.3

# Instalar extensions necessàries de PHP per a Laravel i l'extensió PDO per a base de dades
RUN install-php-extensions \
    pcntl \
    pdo_mysql \
    mbstring \
    xml \
    openssl \
    tokenizer \
    ctype \
    fileinfo

# Configurar el directori de treball del servidor web
WORKDIR /app

# Copiar el codi del projecte
COPY . /app

# Crear estructures de carpetes de Laravel i permisos
RUN mkdir -p /app/storage/framework/cache/data \
    && mkdir -p /app/storage/framework/sessions \
    && mkdir -p /app/storage/framework/views \
    && mkdir -p /app/storage/logs \
    && mkdir -p /app/bootstrap/cache \
    && chmod -R 777 /app/storage /app/bootstrap/cache

# Instalar dependències de Composer de forma neta
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

# Crear el fitxer de salut estàtic dins de public
RUN echo '<?php echo "OK";' > /app/public/health.php

# Indicar el port dinàmic a Railway
EXPOSE $PORT

# Configurar variables perquè FrankenPHP s'adapti automàticament al port de Railway
ENV SERVER_NAME=":${PORT}"

# Arrencada d'alta eficiència apuntant a la carpeta pública de Laravel
CMD ["frankenphp", "php-server", "--public-dir", "public/"]