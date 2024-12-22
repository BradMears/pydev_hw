#!/bin/bash

export UID
export GID=`id -g`

# Search to see if my BusPirate is active
for dev in ttyUSB0 ttyUSB1 ttyUSB2 ACM0 ACM1 ACM2; do
  NAME=/dev/$dev
  if [ -e $NAME ]; then
    udevadm info $NAME | grep A603PJ9U > /dev/null
    if [ $? -eq 0 ]; then
      PIRATE="-v $NAME:/dev/BusPirate"
      echo "PIRATE=$PIRATE"
    fi
  fi
done

# Search to see if any FT232H is active
for dev in ttyUSB0 ttyUSB1 ttyUSB2 ACM0 ACM1 ACM2; do
  NAME=/dev/$dev
  if [ -e $NAME ]; then
    udevadm info $NAME | grep FT232H > /dev/null
    if [ $? -eq 0 ]; then
      FT232H="-v $NAME:/dev/FT232H"
      echo "FT232H=$FT232H"
    fi
  fi
done

docker compose run --rm -e REAL_HOST=${HOSTNAME} ${PIRATE} ${FT232H} --name pydev_hw pydev_hw
