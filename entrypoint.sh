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

#sed -i "/^export APACHE_LOG_DIR/cexport APACHE_LOG_DIR=$HOME/log" "/etc/apache2/envvars"
#sed -i "/^ServerRoot/cServerRoot $HOME/app" "/etc/apache2/httpd.conf"
sed -i "/^Listen/cListen 4320" "/etc/apache2/httpd.conf"
sed -i "/^#ServerName/cServerName $HOSTNAME" "/etc/apache2/httpd.conf"
#ln -sf /var/log/apache2 "$HOME/logs"
#ln -sf /usr/lib/apache2 "$HOME/modules"
#ln -sf /run/apache2 "$HOME/run"
#sed -i "s|'/var/lib/pgadmin'|'$HOME'|gi" "/etc/apache2/httpd.conf"

find "$HOME" ! -group "$GROUP" -exec chgrp "$GROUP_ID" {} \;
find "$HOME" ! -user "$USER" -exec chown "$USER_ID" {} \;

exec "$@"
