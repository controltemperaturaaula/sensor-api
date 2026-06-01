FROM ubuntu:24.04

# Evitar preguntes interactives
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependències, repositori de PHP i Nginx
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    unzip \
    git \
    nginx \
    && add-apt-repository ppa:ondrej/php -y \
    && apt-get update

# Instalar PHP 8.3 FPM i extensions per a Laravel
RUN apt-get install -y \
    php8.3-fpm \
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

# Configurar directori de treball
WORKDIR /var/www/html

# Copiar el projecte
COPY . .

# Instalar paquets de Composer ignorant restriccions estrictes
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

# Configurar Nginx per apuntar a la carpeta pública de Laravel i acceptar el port de Railway
RUN echo 'server { \n\
    listen 80 default_server; \n\
    root /var/www/html/public; \n\
    index index.php index.html; \n\
    location / { \n\
        try_files $uri $uri/ /index.php?$query_string; \n\
    } \n\
    location ~ \.php$ { \n\
        include snippets/fastcgi-php.conf; \n\
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock; \n\
    } \n\
}' > /etc/nginx/sites-available/default

# Ajustar els permisos per a Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Indicar el port dinàmic a Railway
EXPOSE $PORT

# Arrencada: Reconfigurar el port de Nginx dinàmicament en arrencar, encendre FPM i llançar Nginx en primer pla
CMD ["sh", "-c", "sed -i \"s/listen 80/listen $PORT/g\" /etc/nginx/sites-available/default && service php8.3-fpm start && nginx -g \"daemon off;\""]