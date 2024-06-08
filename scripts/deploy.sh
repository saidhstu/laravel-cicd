#!/usr/bin/env bash

# Variables (replace these with your actual values)
DB_DATABASE="${DB_DATABASE}"
DB_USERNAME="${DB_USERNAME}"
DB_PASSWORD="${DB_PASSWORD}"

# Install PHP and Composer if not installed
if ! command -v php &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y php php-cli php-mbstring unzip php-xml
fi

if ! command -v composer &> /dev/null; then
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
fi

# Install MySQL if not installed
if ! command -v mysql &> /dev/null; then
    sudo apt-get install -y mysql-server
    sudo service mysql start
fi

# Configure MySQL
sudo mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE};"
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_DATABASE}.* TO 'root'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Navigate to the project directory
cd /var/www/html/laravelcicd

# Check if composer.lock or composer.json has changed
if [ -f composer.lock ]; then
    LOCK_HASH_LOCAL=$(md5sum composer.lock | awk '{ print $1 }')
    LOCK_HASH_REMOTE=$(ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no ${SSH_USERNAME}@${SSH_HOST} "md5sum /var/www/html/laravelcicd/composer.lock | awk '{ print $1 }'")
    if [ "$LOCK_HASH_LOCAL" != "$LOCK_HASH_REMOTE" ]; then
        echo "composer.lock has changed. Installing dependencies..."
        composer install --prefer-dist --no-progress
    else
        echo "composer.lock has not changed. Skipping composer install."
    fi
else
    echo "composer.lock not found. Installing dependencies..."
    composer install --prefer-dist --no-progress
fi

# Run database migrations
php artisan migrate --force
