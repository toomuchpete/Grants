#!/bin/sh
unicorn_pid=`cat /var/www/grants/shared/tmp/unicorn.pid`
echo "Restarting Unicorn ($unicorn_pid)"
kill -1 $unicorn_pid
