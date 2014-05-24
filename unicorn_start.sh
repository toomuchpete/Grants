#!/bin/sh
unicorn_rails -c /var/www/grants/shared/config/unicorn.rb -D
echo "Starting Unicorn"
