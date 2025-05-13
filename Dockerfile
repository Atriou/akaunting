FROM php:8.1-fpm-bullseye

# Installer dépendances système nécessaires
RUN apt-get update && apt-get install -y \
    zip unzip git curl libpng-dev libjpeg-dev libfreetype6-dev libonig-dev \
    libxml2-dev libzip-dev libpq-dev libicu-dev libxslt-dev libffi-dev libssl-dev \
    libjpeg62-turbo-dev libwebp-dev libxpm-dev libvpx-dev \
    gnupg2 ca-certificates lsb-release wget \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip xml intl fileinfo sodium xsl \
    && apt-get clean

# Installer Node.js 16 (correctement avec NodeSource)
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Définir dossier de travail
WORKDIR /var/www

# Copier les fichiers du projet
COPY . .

# Donner permissions correctes
RUN chown -R www-data:www-data /var/www

# Installer dépendances PHP
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Copier environnement et générer clé Laravel
RUN cp .env.example .env
RUN php artisan key:generate

# Installer dépendances Node.js et builder assets front
RUN npm install
RUN npm run build

# Exposer port HTTP
EXPOSE 8000

# Commande de démarrage
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
