# Imagen base con PHP 8.2
FROM php:8.2-cli

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    unzip git curl zip libzip-dev libpng-dev libonig-dev libxml2-dev \
    sqlite3 libsqlite3-dev libicu-dev nodejs npm \
    && docker-php-ext-install intl pdo_mysql zip

# Copiar composer desde otra imagen
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establecer el directorio de trabajo
WORKDIR /var/www

# Copiar todo el proyecto
COPY . .

# Instalar dependencias JavaScript
RUN npm install && npm run build

# Copiar archivo de entorno
RUN cp .env.example .env

# Instalar dependencias PHP y optimizar
RUN composer install --no-dev --optimize-autoloader

# Generar clave y cachear configuración
RUN php artisan key:generate
RUN php artisan config:cache
RUN php artisan view:cache
RUN php artisan route:cache

# Exponer el puerto 8080 (usado por Railway)
EXPOSE 8080

# Comando por defecto
CMD php artisan serve --host=0.0.0.0 --port=${PORT:-8080}
