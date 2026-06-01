FROM dunglas/frankenphp:1-php8.3

# Instalar extensions del sistema i de PHP necessàries per a Laravel
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -y zip gd pdo pdo_mysql pcntl opcache

# Configurar el directori de treball
WORKDIR /app

# Copiar el codi del projecte
COPY . /app

# Instalar Composer de forma oficial i descarregar dependències
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts

# Variables d'entorn per indicar a FrankenPHP on està el "public" de Laravel
ENV AUTORELOAD=1
ENV SERVER_NAME=:80
ENV FRANKENPHP_CONFIG="web_root /app/public"

# Exposar el port de Railway
EXPOSE 80

# Comando d'arrencada definitiu
CMD ["sh", "-c", "php artisan package:discover --ansi && frankenphp run --config /etc/caddy/Caddyfile"]