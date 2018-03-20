#!/bin/sh

#docker build --tag rekgrpth/cherry . && \
#docker push rekgrpth/cherry
docker stop cherry
docker rm cherry
docker pull rekgrpth/cherry && \
docker volume create cherry && \
docker run \
    --add-host `hostname -f`:`ip -4 addr show docker0 | grep -oP 'inet \K[\d.]+'` \
    --add-host ldap.t72.ru:`getent hosts ldap.t72.ru | cut -d ' ' -f 1` \
    --detach \
    --env USER_ID=$(id -u) \
    --env GROUP_ID=$(id -g) \
    --hostname cherry \
    --name cherry \
    --publish 4320:443 \
    --volume /etc/certs/t72.crt:/etc/apache2/ssl/t72.crt:ro \
    --volume /etc/certs/t72.key:/etc/apache2/ssl/t72.key:ro \
    --volume cherry:/data \
    rekgrpth/cherry
