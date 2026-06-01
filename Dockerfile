FROM ubuntu:24.04

# Evitar preguntes interactives durant la instal·lació
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependències bàsiques i afegir el repositori oficial de PHP actualitzat
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    unzip \
    git \
    && add-apt-repository ppa:ondrej/php -y \
    && apt-get update

# Instalar PHP 8.3 i extensions de Laravel
RUN apt-get install -y \
    php8.3-cli \
    php8.3-common \
    php8.3-mbstring \
    php8.3-xml \
    php8.3-mysql \
    php8.3-tokenizer \
    php8.3-curl \
    php8.3-zip \
    && apt-get clean

# Instalar Composer globalment
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configurar el directori de treball
WORKDIR /app

# Copiar el codi del projecte
COPY . /app

# Instalar paquets de Composer ignorant requisits estrictes de versió de PHP
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

# Indicar el port dinàmic a Railway
EXPOSE $PORT

# Comando d'arrencada definitiu utilitzant el port de Railway
CMD ["sh", "-c", "php artisan package:discover --ansi || true && php -S 0.0.0.0:$PORT -t public"]