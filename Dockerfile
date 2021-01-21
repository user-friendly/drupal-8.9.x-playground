# Based on the Drupal docker example at https://github.com/ricardoamaro/drupal8-docker-app/blob/master/Dockerfile

# TODO Do not reference a specific PHP version or
#      at least centralize it.

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

# TODO The MariaDB client is required by drush. It adds some 60MB to the image.
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales git curl unzip wget openssh-client mariadb-client ssl-cert ca-certificates \
    php-fpm apache2 php php-cli php-common php-gd php-json php-mbstring php-xdebug \
    php-mysql php-opcache php-curl php-readline php-xml php-memcached php-oauth php-bcmath \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && echo "Cleaning up..." \
    && apt-get clean; apt-get autoclean; apt-get -y autoremove; \
    rm -rf /var/lib/apt/lists/*

ENV LANG en_US.utf8

# Apache, PHP-FPM & Xdebug.
# In case mod-php was installed remove it. We'll be using FPM.
RUN apt-get remove -y libapache2-mod-php7.4
RUN rm -Rf /var/www/html /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/*
ADD ./docker-files/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2ensite 000-default ; a2enmod proxy_fcgi rewrite vhost_alias
ADD ./docker-files/xdebug.ini /etc/php/7.4/mods-available/xdebug.ini
ADD ./docker-files/app.ini /etc/php/7.4/mods-available/app.ini
RUN phpenmod app

# Setup application user.
COPY ./docker-files/.bash_aliases /etc/skel
COPY ./docker-files/id_rsa* /tmp/ 
ARG HOST_DEV_USER=developer
ARG HOST_DEV_UID=1000
ARG HOST_DEV_HOME=/home/$HOST_DEV_USER
RUN useradd -mUu $HOST_DEV_UID $HOST_DEV_USER \
    && mkdir $HOST_DEV_HOME/bin $HOST_DEV_HOME/.ssh \
    && mv /tmp/id_rsa* $HOST_DEV_HOME/.ssh && chmod 0700 $HOST_DEV_HOME/.ssh \
    && chown -R $HOST_DEV_USER:$HOST_DEV_USER $HOST_DEV_HOME/bin $HOST_DEV_HOME/.ssh \
    && echo "\n"'COMPOSER_HOME=$HOME/composer' >> $HOST_DEV_HOME/.bashrc \
    && echo "\n"'PATH="$HOME/bin:$COMPOSER_HOME/vendor/bin:$PATH"' >> $HOST_DEV_HOME/.bashrc \
    && echo "APP_USER=$HOST_DEV_USER\nAPP_UID=$HOST_DEV_UID" > /home/appuser \
    && sed -i "s/www-data/$HOST_DEV_USER/" /etc/apache2/envvars /etc/php/7.4/fpm/pool.d/www.conf \
    && find / -user www-data -not -path '/proc/*' -exec chown -v -h $HOST_DEV_USER '{}' \; \
    && find / -group www-data -not -path '/proc/*' -exec chgrp -v $HOST_DEV_USER '{}' \;

ENV DEBIAN_FRONTEND newt

# TODO Use supervisord to manage processes?

# RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd; \
#  echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config; \
#  locale-gen en_US.UTF-8; \
#  mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor

# Install Composer, drush and drupal console
USER $HOST_DEV_USER
RUN export COMPOSER_HOME=$HOME/composer \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=$HOME/bin --filename=composer \
  && $HOME/bin/composer global require drush/drush:~8 \
  && curl https://drupalconsole.com/installer -L -o $HOME/bin/drupal \
  && chmod +x $HOME/bin/drupal
USER $HOST_DEV_USER
RUN PATH="$HOME/bin:$HOME/composer/vendor/bin:$PATH"; \
    echo $PATH; php --version; composer --version; drupal --version; drush --version
USER root

# Root account convenience aliases.
COPY ./docker-files/.bash_aliases /root/

COPY ./docker-files/start.sh /

EXPOSE 80 443 9000

CMD [ "/bin/bash", "/start.sh" ]
