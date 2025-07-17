FROM php:8.2-cli

RUN apt-get update && apt-get install -y \
    unzip git curl zip libzip-dev libpng-dev libonig-dev libxml2-dev sqlite3 libsqlite3-dev libicu-dev nodejs npm \
    && docker-php-ext-install intl pdo_mysql zip

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

# Instalar dependencias JS y compilar assets
RUN npm install
RUN npm run build

# Copiar archivo de entorno
RUN cp .env.example .env

# Instalar dependencias PHP sin dev y optimizar autoload
RUN composer install --no-dev --optimize-autoloader

# Generar key y cachear configuración, vistas y rutas
RUN php artisan key:generate
RUN php artisan config:cache
RUN php artisan view:cache
RUN php artisan route:cache

EXPOSE 8080

CMD php artisan serve --host=0.0.0.0 --port=${PORT:-8080}
