#!/bin/sh

sed -i "/^#ServerName/cServerName ${HOSTNAME}" "/etc/apache2/httpd.conf"
sed -i "/^ServerAdmin/cServerAdmin cherry@${HOSTNAME}" "/etc/apache2/httpd.conf"

if [ "$GROUP" != "" ]; then
    if [ "$GROUP_ID" = "" ]; then GROUP_ID=$(id -g "$GROUP"); fi
    if [ "$GROUP_ID" != "$(id -g "$GROUP")" ]; then
        groupmod --gid "$GROUP_ID" "$GROUP"
    fi
    find "$HOME" ! -group "$GROUP" -exec chgrp "$GROUP_ID" {} \; &
fi
if [ "$USER" != "" ]; then
    if [ "$USER_ID" = "" ]; then USER_ID=$(id -u "$USER"); fi
    if [ "$USER_ID" != "$(id -u "$USER")" ]; then
        usermod --uid "$USER_ID" "$USER"
    fi
    find "$HOME" ! -user "$USER" -exec chown "$USER_ID" {} \; &
    exec "$@"
else
    exec "$@"
fi
