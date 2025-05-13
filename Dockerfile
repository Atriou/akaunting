# Utiliser une image PHP+Node préinstallée
FROM thecodingmachine/php:8.1-v4-cli-node14

# Définir le dossier de travail
WORKDIR /var/www

# Copier tous les fichiers
COPY . .

# Copier l'environnement et générer une clé Laravel
RUN cp .env.example .env && php artisan key:generate

# Installer dépendances PHP
RUN composer install --optimize-autoloader

# Installer dépendances Node.js et builder frontend
RUN npm install
RUN NODE_OPTIONS="--max-old-space-size=1024" npm run build

# Donner les permissions
RUN chown -R www-data:www-data /var/www

# Exposer le port
EXPOSE 8000

# Lancer l'application Laravel
CMD php artisan migrate --seed && php artisan serve --host=0.0.0.0 --port=8000
