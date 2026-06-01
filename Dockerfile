FROM dunglas/frankenphp:1-php8.3

# Instalar extensions de PHP necessàries per a Laravel
RUN install-php-extensions \
    pcntl \
    pdo_mysql \
    mbstring \
    xml \
    openssl \
    tokenizer \
    ctype \
    fileinfo

# Instalar Composer manualment de forma oficial dins de la imatge
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configurar el directori de treball
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

# Instalar dependències de Composer (ara que ja tenim Composer instal·lat)
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

# Crear el fitxer de salut estàtic dins de public
RUN echo '<?php echo "OK";' > /app/public/health.php

# Configurem FrankenPHP perquè agafi el port dinàmic que Railway li injectarà en arrencar
ENV SERVER_NAME=":8080"

# Arrencada d'alta eficiència apuntant a la carpeta pública de Laravel
CMD ["frankenphp", "php-server", "--public-dir", "public/"]