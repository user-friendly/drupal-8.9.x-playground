# Based on the Drupal docker example at https://github.com/ricardoamaro/drupal8-docker-app/blob/master/Dockerfile

# TODO Do not reference a specific PHP version or
#      at least centralize it.

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    locales git curl unzip wget ssl-cert ca-certificates \
    php-fpm apache2 \
    php php-cli php-common php-gd php-json php-mbstring php-xdebug \
    php-mysql php-opcache php-curl php-readline php-xml php-memcached php-oauth php-bcmath \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && echo "Cleaning up..." \
    && apt-get clean; apt-get autoclean; apt-get -y autoremove; \
    rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND newt
ENV LANG en_US.utf8

# Apache, PHP-FPM & Xdebug.
# In case mod-php was installed remove it. We'll be using FPM.
RUN apt-get remove -y libapache2-mod-php7.4
RUN rm /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/*
ADD ./docker-files/000-default.conf /etc/apache2/sites-available/000-default.conf
ADD ./docker-files/xdebug.ini /etc/php/7.4/mods-available/xdebug.ini
RUN a2ensite 000-default ; a2enmod proxy_fcgi rewrite vhost_alias

# TODO Use supervisord to manage processes?

# RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd; \
#  echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config; \
#  locale-gen en_US.UTF-8; \
#  mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor

# TODO Install PHP related tools for www-data only!
# Install Composer, drush and drupal console
ENV COMPOSER_HOME="/root/.composer"
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && /usr/local/bin/composer global require drush/drush:~8 \
  && ln -s $COMPOSER_HOME/vendor/drush/drush/drush /usr/local/bin/drush \
  && curl https://drupalconsole.com/installer -L -o /usr/local/bin/drupal \
  && chmod +x /usr/local/bin/drupal

RUN php --version; composer --version; drupal --version; drush --version

COPY ./docker-files/.bash_aliases /root/
COPY ./docker-files/start.sh /

EXPOSE 80 443 9000

CMD [ "/bin/bash", "/start.sh" ]
