#!/bin/bash

export UID
export GID=`id -g`
docker compose run --rm -e REAL_HOST=${HOSTNAME} --name pydev_hw pydev_hw
