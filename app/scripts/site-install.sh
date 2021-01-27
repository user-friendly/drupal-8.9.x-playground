#!/usr/bin/env bash

cd /var/www

# Assumes global drush is available.
DRUSH="drush"

# Global options.
EXTRA_OPTS=""

# Domain name and directory in web/sites.
SITE_DOMAIN="example.drupal8.local"

# Site's name.
SITE_NAME="Example Demo"

# Profile to install.
PROFILE="standard"

# Disables auto module update checks and email notifications. 
FORM_CONFIG="install_configure_form.enable_update_status_module=NULL
             install_configure_form.enable_update_status_emails=NULL
             "

CMD="$DRUSH $EXTRA_OPTS site-install $PROFILE $FORM_CONFIG"

echo "Installing site $SITE_NAME"
# TODO Look into the --config-dir option.
# ATT Do not use the super DB user for both --db-su args and the site DB user.
#     The installer restricts the DB user privileges. 
set -x
$CMD    --site-name=$SITE_NAME \
        --locale=en \
        --db-su=root \
        --db-su-pw=root \
        --db-url=mysql://example:example@db/example \
        --account-name=admin \
        --account-pass=admin \
        --account-mail=webmaster@localhost \
        --site-mail=webmaster@localhost \
        --sites-subdir=$SITE_DOMAIN
set +x
