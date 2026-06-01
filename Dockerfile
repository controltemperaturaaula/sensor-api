FROM php:8.3-apache

# 1. Instalar eines de sistema i extensions de PHP per a Laravel
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libxml2-dev \
    libonig-dev \
    && docker-php-ext-install pdo_mysql mbstring xml \
    && apt-get clean

# 2. Instalar Composer globalment
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 3. Moure la configuració d'Apache perquè apunti a la carpeta 'public' de Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# 4. Activar el mòdul 'rewrite' d'Apache (vital per a les rutes de Laravel)
RUN a2enmod rewrite

# 5. Configurar el directori de treball i copiar el projecte
WORKDIR /var/www/html
COPY . .

# 6. Crear carpetes i permisos estructurals de Laravel
RUN mkdir -p storage/framework/cache/data \
    && mkdir -p storage/framework/sessions \
    && mkdir -p storage/framework/views \
    && mkdir -p storage/logs \
    && mkdir -p bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 777 storage bootstrap/cache

# 7. Executar la instal·lació de Composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

# 8. Crear el fitxer de salut estàtic
RUN echo '<?php echo "OK";' > /var/www/html/public/health.php

# 9. ARRENCADA DINÀMICA: Escriure el port real de Railway dins de la configuració d'Apache just abans d'arrencar
CMD ["sh", "-c", "sed -i \"s/Listen 80/Listen $PORT/g\" /etc/apache2/ports.conf && sed -i \"s/<VirtualHost \*:80>/<VirtualHost \*:$PORT>/g\" /etc/apache2/sites-available/*.conf && apache2-foreground"]