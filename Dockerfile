FROM richarvey/nginx-php-fpm:3.1.6

# Configurar el directorio de trabajo
WORKDIR /var/www/html

# Copiar los archivos del proyecto
COPY . .

# Instalar dependencias de Composer sin ejecutar scripts problemáticos en el build
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts

# Configurar variables de entorno para Nginx
ENV WEBROOT=/var/www/html/public
ENV APP_ENV=production

# Exponer el puerto que nos da Railway
EXPOSE 80

# Comando de arranque optimizado en formato JSON
CMD ["sh", "-c", "php artisan package:discover --ansi && /start.sh"]