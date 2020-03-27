#!/bin/sh

#docker build --tag rekgrpth/cherry . || exit $?
#docker push rekgrpth/cherry || exit $?
docker pull rekgrpth/cherry || exit $?
docker volume create cherry || exit $?
docker network create --attachable --opt com.docker.network.bridge.name=docker docker || echo $?
docker stop cherry || echo $?
docker rm cherry || echo $?
docker run \
    --detach \
    --env GROUP_ID=$(id -g) \
    --env LANG=ru_RU.UTF-8 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID=$(id -u) \
    --hostname cherry \
    --name cherry \
    --network name=docker \
    --restart always \
    --volume cherry:/home \
    --volume /etc/certs:/etc/certs \
    --volume /run/postgresql:/run/postgresql \
    --volume /run/uwsgi:/run/uwsgi \
    rekgrpth/cherry uwsgi --ini cherry.ini
