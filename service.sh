#!/bin/sh

#docker build --tag rekgrpth/cherry . || exit $?
#docker push rekgrpth/cherry || exit $?
docker pull rekgrpth/cherry || exit $?
docker volume create cherry || exit $?
docker network create --attachable --driver overlay docker || echo $?
docker service create \
    --env GROUP_ID=$(id -g) \
    --env LANG=ru_RU.UTF-8 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID=$(id -u) \
    --hostname cherry \
    --mount type=bind,source=/etc/certs,destination=/etc/certs \
    --mount type=volume,source=cherry,destination=/home \
    --name cherry \
    --network name=docker \
    rekgrpth/cherry uwsgi --ini cherry.ini
