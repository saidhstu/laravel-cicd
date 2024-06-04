#!/usr/bin/env bash

cd /var/www/html/laravelcicd
composer install --prefer-dist --no-progress --no-suggest
php artisan migrate --force