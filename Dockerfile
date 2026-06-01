FROM shivammathur/node-php:8.3

# Configurar el directori de treball
WORKDIR /var/www/html

# Copiar el codi del projecte
COPY . .

# Instalar dependències de Composer (sense scripts que puguin fallar)
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts

# Exposar el port de Railway
EXPOSE 80

# Arrencar el servidor de Laravel directament
CMD ["sh", "-c", "php artisan package:discover --ansi && php artisan serve --host=0.0.0.0 --port=80"]