FROM php:8.4-apache

# 1. Instalar herramientas de sistema y extensiones de PHP para Laravel 13
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libxml2-dev \
    libonig-dev \
    && docker-php-ext-install pdo_mysql mbstring xml \
    && apt-get clean

# 2. Instalar Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 3. Definir variable de entorno para la carpeta pública
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

# 4. Configurar Apache para apuntar a la carpeta pública de Laravel
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# 5. Activar el módulo rewrite de Apache
RUN a2enmod rewrite

# 6. Configurar directorio de trabajo y copiar el proyecto limpio
WORKDIR /var/www/html
COPY . .

# 7. Crear carpetas estructurales y dar permisos absolutos
RUN mkdir -p storage/framework/cache/data \
    && mkdir -p storage/framework/sessions \
    && mkdir -p storage/framework/views \
    && mkdir -p storage/logs \
    && mkdir -p bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 777 storage bootstrap/cache

# 8. Instalar dependencias de Composer normales (sin ignorar plataforma, porque ya estamos en PHP 8.4)
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts

# Exponer el puerto estándar 80
EXPOSE 80

# 9. Arrancar Apache en primer plano
CMD ["apache2-foreground"]