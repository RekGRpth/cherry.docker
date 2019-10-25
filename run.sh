#!/bin/sh

#docker build --tag rekgrpth/cherry . || exit $?
#docker push rekgrpth/cherry || exit $?
docker stop cherry
docker rm cherry
docker pull rekgrpth/cherry || exit $?
docker volume create cherry || exit $?
docker network create --opt com.docker.network.bridge.name=docker docker
docker run \
    --detach \
    --env GROUP_ID=$(id -g) \
    --env USER_ID=$(id -u) \
    --hostname cherry \
    --link nginx:django-$(hostname -f) \
    --link nginx:$(hostname -f) \
    --name cherry \
    --network docker \
    --restart always \
    --volume cherry:/home \
    rekgrpth/cherry uwsgi --ini cherry.ini
