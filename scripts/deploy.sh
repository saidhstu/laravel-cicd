#!/bin/bash
set -e

echo "Deployment started ..."

# Enter maintenance mode or return true if already in maintenance mode
(php artisan down) || true

# Clear the old cache
php artisan clear-compiled

# Recreate cache
php artisan optimize

# Compile npm assets
yarn
yarn build

# Run database migrations
php artisan migrate --force

# Exit maintenance mode
php artisan up

echo "Deployment finished!"
