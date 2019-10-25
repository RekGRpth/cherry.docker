#!/bin/sh

#docker build --tag rekgrpth/cherry . || exit $?
#docker push rekgrpth/cherry || exit $?
docker stop cherry
docker rm cherry
docker pull rekgrpth/cherry || exit $?
docker volume create cherry || exit $?
docker network create --opt com.docker.network.bridge.name=docker docker
docker run \
    --add-host ldap.t72.ru:$(getent hosts ldap.t72.ru | cut -d ' ' -f 1) \
    --detach \
    --env GROUP_ID=$(id -g) \
    --env HOSTNAME=cherry-$(hostname -f) \
    --env USER_ID=$(id -u) \
    --hostname cherry \
    --link nginx:django-$(hostname -f) \
    --link nginx:$(hostname -f) \
    --name cherry \
    --network docker \
    --restart always \
    --volume cherry:/home \
    --volume /etc/certs/$(hostname -d).crt:/etc/ssl/apache2/server.pem \
    --volume /etc/certs/$(hostname -d).key:/etc/ssl/apache2/server.key \
    --volume /var/lib/docker/volumes/cherry/_data/apache2.conf:/etc/apache2/conf.d/ssl.conf \
    rekgrpth/cherry
