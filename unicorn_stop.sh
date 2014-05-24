#!/bin/sh
unicorn_pid=`cat /var/www/grants/shared/tmp/unicorn.pid`
echo "Stopping Unicorn ($unicorn_pid)"
kill -9 $unicorn_pid
