#!/usr/bin/env bash

# Install PHP and Composer if not installed
if ! command -v php &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y php php-cli php-mbstring unzip
fi

if ! command -v composer &> /dev/null; then
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
fi

# Navigate to the project directory
cd /var/www/html/laravelcicd

# Install dependencies
composer install --prefer-dist --no-progress --no-suggest

# Run database migrations
php artisan migrate --force
