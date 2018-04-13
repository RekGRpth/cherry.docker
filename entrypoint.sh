#!/bin/sh

if [ "$GROUP_ID" = "" ]; then GROUP_ID=$(id -g "$GROUP"); fi
if [ "$GROUP_ID" != "$(id -g "$GROUP")" ]; then
    find / -group "$GROUP" -exec chgrp "$GROUP_ID" {} \;
    groupmod --gid "$GROUP_ID" "$GROUP"
fi

if [ "$USER_ID" = "" ]; then USER_ID=$(id -u "$USER"); fi
if [ "$USER_ID" != "$(id -u "$USER")" ]; then
    find / -user "$USER" -exec chown "$USER_ID" {} \;
    usermod --uid "$USER_ID" "$USER"
fi

rm -rf /var/www/localhost/htdocs && ln -sf "$HOME/app" /var/www/localhost/htdocs
rm -rf /var/www/logs && ln -sf "$HOME/log" /var/www/logs

#sed -i "/^export APACHE_LOG_DIR/cexport APACHE_LOG_DIR=$HOME/log" "/etc/apache2/envvars"
#sed -i "/^ServerRoot/cServerRoot $HOME/app" "/etc/apache2/httpd.conf"
#sed -i "/^Listen/cListen 4320" "/etc/apache2/httpd.conf"
sed -i "/^#ServerName/cServerName $HOSTNAME" "/etc/apache2/httpd.conf"
#sed -i "/^LogLevel/cLogLevel info" "/etc/apache2/httpd.conf"
sed -i "/^LogLevel/cLogLevel info" "/etc/apache2/httpd.conf"
#sed -i "/^ServerName/cServerName $HOSTNAME:443" "/etc/apache2/conf.d/ssl.conf"
sed -i "/^ServerAdmin/cServerAdmin cherry@$HOSTNAME" "/etc/apache2/httpd.conf"
#sed -i "/^ServerAdmin/cServerAdmin cherry@$HOSTNAME" "/etc/apache2/conf.d/ssl.conf"
sed -i "s|#AddHandler cgi-script .cgi|AddHandler cgi-script .cgi|g" "/etc/apache2/httpd.conf"
#sed -i "/^ServerName/cServerName $HOSTNAME:443" "/etc/apache2/conf.d/ssl.conf"
#DocumentRoot "/var/www/localhost/htdocs"
sed -i "s|#LoadModule rewrite|LoadModule rewrite|g" "/etc/apache2/httpd.conf"
sed -i "s|#LoadModule cgi|LoadModule cgi|g" "/etc/apache2/httpd.conf"
sed -i "s|#LoadModule suexec|LoadModule suexec|g" "/etc/apache2/httpd.conf"
sed -i "s|#LoadModule include|LoadModule include|g" "/etc/apache2/httpd.conf"
sed -i "s|#LoadModule log|LoadModule log|g" "/etc/apache2/httpd.conf"
#LoadModule rewrite_module modules/mod_rewrite.so
#ln -sf /var/log/apache2 "$HOME/logs"
#ln -sf /usr/lib/apache2 "$HOME/modules"
#ln -sf /run/apache2 "$HOME/run"
#sed -i "s|'/var/lib/pgadmin'|'$HOME'|gi" "/etc/apache2/httpd.conf"
#sed -i "s| modules/| /usr/lib/apache2/|g" "/etc/apache2/httpd.conf"
#sed -i "s| modules/| /usr/lib/apache2/|g" "/etc/apache2/conf.d/ssl.conf"
#sed -i "s|logs/error.log|$HOME/log/error.log|g" "/etc/apache2/httpd.conf"
#sed -i "s|logs/access.log|$HOME/log/access.log|g" "/etc/apache2/httpd.conf"
#sed -i "s|logs/ssl_|$HOME/log/ssl.|g" "/etc/apache2/conf.d/ssl.conf"

find "$HOME" ! -group "$GROUP" -exec chgrp "$GROUP_ID" {} \;
find "$HOME" ! -user "$USER" -exec chown "$USER_ID" {} \;

exec "$@"
