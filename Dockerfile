FROM alpine:3.20

# Instalar PHP 8.3 i les extensions necessàries de Laravel
RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/v3.20/community \
    php83 \
    php83-cli \
    php83-common \
    php83-mbstring \
    php83-xml \
    php83-openssl \
    php83-pdo \
    php83-pdo_mysql \
    php83-tokenizer \
    php83-ctype \
    php83-session \
    php83-dom \
    php83-xmlwriter \
    php83-fileinfo \
    composer

# Enllaços simbòlics correctes perquè el sistema trobi 'php' i 'composer' globalment
RUN ln -sf /usr/bin/php83 /usr/bin/php && \
    ln -sf /usr/bin/composer /usr/local/bin/composer

# Configurar el directori de treball
WORKDIR /app

# Copiar el codi del projecte
COPY . /app

# Instalar dependències de Composer (sense scripts al build)
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

# Indiquem a Railway que farem servir el seu port dinàmic
EXPOSE $PORT

# COMANDO D'ARRENCADA: Escriurem el port real al log per comprovar-ho i aixequem el servidor natari usant la variable $PORT de Railway
CMD ["sh", "-c", "echo \"🚀 Arrencant en el port ofert per Railway: $PORT\" && php artisan package:discover --ansi || true && php -S 0.0.0.0:$PORT -t public"]