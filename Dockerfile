FROM dunglas/frankenphp:1-php8.3

# Instalar 'unzip' al sistema Linux (necessari per a Composer)
RUN apt-get update && apt-get install -y unzip && apt-get clean

# Instalar extensions de PHP (afegint l'extensió 'zip')
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

# Instalar Composer globalment
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

# Instalar dependències de Composer (ara sí que podrà descomprimir-les)
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

# Crear el fitxer de salut de contingència dins de public
RUN echo '<?php echo "OK";' > /app/public/health.php

# Configurar port estàndard per a FrankenPHP
ENV SERVER_NAME=":8080"

# Arrencada en mode servidor web professional apuntant a public/
CMD ["frankenphp", "php-server", "--public-dir", "public/"]