#!/bin/sh -x

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
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=bind,source=/run/postgresql,destination=/run/postgresql \
    --mount type=bind,source=/run/uwsgi,destination=/run/uwsgi \
    --mount type=volume,source=cherry,destination=/home \
    --name cherry \
    --network name=docker \
    --restart always \
    rekgrpth/cherry uwsgi --ini cherry.ini
