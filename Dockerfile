FROM php:8.4-apache

# 1. Instalar exclusivament les eines i extensions necessàries per a Laravel 13
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libxml2-dev \
    libonig-dev \
    && docker-php-ext-install pdo_mysql mbstring xml \
    && apt-get clean

# 2. Instalar Composer globalment
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 3. Moure el directori de treball a la ruta per defecte d'Apache
WORKDIR /var/www/html
COPY . .

# 4. Crear carpetes estructurals i assignar permisos totals a l'usuari d'Apache (www-data)
RUN mkdir -p storage/framework/cache/data \
    && mkdir -p storage/framework/sessions \
    && mkdir -p storage/framework/views \
    && mkdir -p storage/logs \
    && mkdir -p bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 777 storage bootstrap/cache

# 5. Instalar dependències de Composer de producció
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts

# 6. Crear el fitxer de salut estàtic
RUN echo '<?php echo "OK";' > /var/www/html/health.php

# Exposar el port estàndard
EXPOSE 80

# El comando final es llançarà automàticament des del panell de Railway com hem configurat
CMD ["apache2-foreground"]