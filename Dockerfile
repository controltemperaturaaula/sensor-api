FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar paquets del sistema operatiu
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

# 2. Instalar Composer globalment
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 3. Configurar directori de treball i copiar el projecte
WORKDIR /app
COPY . /app

# 4. Crear estructures obligatòries de carpetes i aplicar permisos reals
RUN mkdir -p /app/storage/framework/cache/data \
    && mkdir -p /app/storage/framework/sessions \
    && mkdir -p /app/storage/framework/views \
    && mkdir -p /app/storage/logs \
    && mkdir -p /app/bootstrap/cache \
    && chmod -R 777 /app/storage /app/bootstrap/cache

# 5. Executar la instal·lació de Composer (Forçada en el build de forma seqüencial)
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

# 6. Crear el fitxer de salut estàtic de contingència
RUN echo '<?php echo "OK";' > /app/public/health.php

EXPOSE $PORT

# 7. ARRENCADA NETEJA: Executem el servidor pur directament des de la carpeta pública
CMD ["sh", "-c", "cd /app/public && php -S 0.0.0.0:$PORT"]