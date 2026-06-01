FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalar només el PHP essencial per estalviar memòria RAM a Railway
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

# Copiar el codi net (gràcies al .dockerignore)
COPY . /app

# Instalar dependències des de zero de forma optimitzada
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

EXPOSE $PORT

# Arrencada directa: evitem tancaments si falla artisan i aixequem el servidor web de baix consum
CMD ["sh", "-c", "php artisan package:discover --ansi || true && php -S 0.0.0.0:$PORT -t public"]