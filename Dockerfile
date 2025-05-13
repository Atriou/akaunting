FROM php:8.1-fpm-bullseye

# Installer dépendances système
RUN apt-get update && apt-get install -y \
    zip unzip git curl libpng-dev libonig-dev libxml2-dev libzip-dev libpq-dev libjpeg-dev libfreetype6-dev \
    gnupg2 ca-certificates lsb-release wget \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Installer Node.js (version 16 stable)
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs

# Définir le dossier de travail
WORKDIR /var/www

# Copier les fichiers du projet
COPY . .

# Définir les permissions
RUN chown -R www-data:www-data /var/www

# Installer les dépendances PHP
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Copier l'environnement
RUN cp .env.example .env

# Générer la clé Laravel
RUN php artisan key:generate

# Installer dépendances Node.js et builder les assets
RUN npm install
RUN npm run build

# Exposer le port HTTP
EXPOSE 8000

# Lancer le serveur
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]


# Démarrer le serveur PHP intégré
CMD php artisan serve --host=0.0.0.0 --port=8000
