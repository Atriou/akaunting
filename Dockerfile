# Utiliser PHP 8.1 avec FPM (mode serveur)
FROM php:8.1-fpm-bullseye

# Installer dépendances système
RUN apt-get update && apt-get install -y \
    zip unzip git curl libpng-dev libjpeg-dev libfreetype6-dev libonig-dev \
    libxml2-dev libzip-dev libpq-dev libicu-dev libxslt-dev libffi-dev libssl-dev \
    libjpeg62-turbo-dev libwebp-dev libxpm-dev libvpx-dev \
    gnupg2 ca-certificates lsb-release wget nodejs npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip xml intl fileinfo sodium xsl \
    && apt-get clean

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Installer Node.js v16 proprement (plus stable que Debian bullseye nodejs)
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs

# Définir dossier de travail
WORKDIR /var/www

# Copier tous les fichiers du projet
COPY . .

# Droits corrects pour Laravel
RUN chown -R www-data:www-data /var/www

# Installer dépendances PHP
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Préparer l'environnement Laravel
RUN cp .env.example .env

# Générer clé d'application
RUN php artisan key:generate

# Installer dépendances Node.js et builder assets
RUN npm install
RUN npm run build

# Exposer le port HTTP (8000 pour Render)
EXPOSE 8000

# Commande de démarrage
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
