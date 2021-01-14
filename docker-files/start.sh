#!/bin/bash

# Setup www-data user.
# At this time, the /var/www/html bind should be mounted
# and the host user/group ids should be available.
OLD_UID=`id --user www-data`
OLD_GID=`id --group www-data`
#NEW_UID=`stat --format '%u' /var/www/html`
#NEW_GID=`stat --format '%g' /var/www/html`
NEW_UID=`/bin/ls -nd /var/www/html | awk '{ print $3 }'`
NEW_GID=`/bin/ls -nd /var/www/html | awk '{ print $4 }'`

usermod -u $NEW_UID www-data
groupmod -g $NEW_GID www-data

find / -uid $OLD_UID -not -path '/proc/*' -exec chown -v -h $NEW_UID '{}' \; -exec echo '{}' \;
find / -gid $OLD_GID -not -path '/proc/*' -exec chgrp -v $NEW_GID '{}' \; -exec echo '{}' \;

echo "Start the Apache2 service."
#service apache2 start

echo "Start the PHP-FPM service."
echo "TODO: start php-fpm"

trap "echo Stopping web service container.; sleep 1; exit" EXIT TERM KILL SIGKILL SIGTERM SIGQUIT SIGINT
while :
do
    sleep 1
done;
