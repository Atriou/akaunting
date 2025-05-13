FROM thecodingmachine/php:8.1-v4-cli-node14

WORKDIR /var/www

COPY . .

# Copier l'environnement
RUN cp .env.example .env

# Installer dépendances PHP (obligatoire AVANT artisan)
RUN composer install --optimize-autoloader

# Générer la clé Laravel
RUN php artisan key:generate

# Installer dépendances Node.js
RUN npm install

# Builder assets frontend
RUN NODE_OPTIONS="--max-old-space-size=1024" npm run build

# Donner les bonnes permissions
RUN chown -R www-data:www-data /var/www

# Exposer port HTTP
EXPOSE 8000

# Lancer l'application
CMD php artisan migrate --seed && php artisan serve --host=0.0.0.0 --port=8000
