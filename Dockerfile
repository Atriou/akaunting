# Étape 1: build PHP + Node.js + Composer
FROM php:8.1-fpm-bullseye

# Installer dépendances système
RUN apt-get update && apt-get install -y \
    zip unzip git curl libpng-dev libonig-dev libxml2-dev libzip-dev libpq-dev \
    gnupg2 ca-certificates lsb-release wget \
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

# Installer dépendances PHP
RUN composer install --optimize-autoloader --no-dev

# Copier le fichier .env exemple
RUN cp .env.example .env

# Générer la clé d'application
RUN php artisan key:generate

# Installer dépendances Node.js
RUN npm install
RUN npm run build

# Donner les permissions correctes
RUN chown -R www-data:www-data /var/www

# Exposer le port HTTP
EXPOSE 8000

# Démarrer le serveur PHP intégré
CMD php artisan serve --host=0.0.0.0 --port=8000
