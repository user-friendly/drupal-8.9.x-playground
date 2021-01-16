#!/bin/bash

# Setup www-data user.
# At this time, the /var/www bind should be mounted
# and the host user/group ids should be available.
#OLD_UID=`id --user www-data`
#OLD_GID=`id --group www-data`
#NEW_UID=`stat --format '%u' /var/www`
#NEW_GID=`stat --format '%g' /var/www`
#NEW_UID=`/bin/ls -nd /var/www | awk '{ print $3 }'`
#NEW_GID=`/bin/ls -nd /var/www | awk '{ print $4 }'`

#usermod -u $NEW_UID www-data
#groupmod -g $NEW_GID www-data

#find / -uid $OLD_UID -not -path '/proc/*' -exec chown -v -h $NEW_UID '{}' \; -exec echo '{}' \;
#find / -gid $OLD_GID -not -path '/proc/*' -exec chgrp -v $NEW_GID '{}' \; -exec echo '{}' \;

echo "Start the Apache2 service."
service apache2 start

echo "Start the PHP-FPM service."
# Grab the highest php-fpm version. TODO This is ugly. Is there a better way?
PHP_FPM_SERVICE=`/bin/ls /etc/init.d/php*fpm | sort -r | awk -F '/' 'NR==1 { print $4 }'`
service $PHP_FPM_SERVICE start

trap "echo Stopping web service container.; sleep 1; exit" EXIT TERM KILL SIGKILL SIGTERM SIGQUIT SIGINT
while :
do
    sleep 1
done;
