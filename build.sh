#!/bin/sh -eux

DOCKER_BUILDKIT=1 docker build --progress=plain --tag rekgrpth/cherry . 2>&1 | tee build.log
