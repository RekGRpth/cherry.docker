#!/bin/sh -ex

#docker build --tag rekgrpth/cherry .
#docker push rekgrpth/cherry
docker pull rekgrpth/cherry
docker volume create cherry
docker network create --attachable --driver overlay docker || echo $?
docker service rm cherry || echo $?
docker service create \
    --env GROUP_ID=$(id -g) \
    --env LANG=ru_RU.UTF-8 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID=$(id -u) \
    --hostname="{{.Service.Name}}-{{.Node.Hostname}}" \
    --mode global \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=bind,source=/run/postgresql,destination=/run/postgresql \
    --mount type=bind,source=/run/uwsgi,destination=/run/uwsgi \
    --mount type=volume,source=cherry,destination=/home \
    --name cherry \
    --network name=docker \
    rekgrpth/cherry uwsgi --ini cherry.ini
