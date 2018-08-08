#!/bin/sh

#docker build --tag rekgrpth/cherry . || exit $?
#docker push rekgrpth/cherry || exit $?
docker stop cherry
docker rm cherry
docker pull rekgrpth/cherry || exit $?
docker volume create cherry || exit $?
docker run \
    --add-host `hostname -f`:`ip -4 addr show docker0 | grep -oP 'inet \K[\d.]+'` \
    --add-host cherry-`hostname -f`:`ip -4 addr show docker0 | grep -oP 'inet \K[\d.]+'` \
    --add-host ldap.t72.ru:`getent hosts ldap.t72.ru | cut -d ' ' -f 1` \
    --detach \
    --env USER_ID=$(id -u) \
    --env GROUP_ID=$(id -g) \
    --env HOSTNAME=cherry-`hostname -f` \
    --hostname cherry \
    --name cherry \
    --publish 4320:443 \
    --restart always \
    --volume /etc/certs/t72.crt:/etc/ssl/apache2/server.pem:ro \
    --volume /etc/certs/t72.key:/etc/ssl/apache2/server.key:ro \
    --volume cherry:/data \
    --volume /var/lib/docker/volumes/cherry/_data/apache2.conf:/etc/apache2/conf.d/ssl.conf:ro \
    rekgrpth/cherry
