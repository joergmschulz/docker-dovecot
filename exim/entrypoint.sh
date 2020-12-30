#!/bin/bash


printf "inject ${EXIM_USER}:${EXIM_GROUP} as default user"
printf "I am $(id -a)"

mkdir -p /var/log/exim
chown -R ${EXIM_USER}:${EXIM_GROUP} /var/log/exim

set -e
# now we'd execute exim...

/usr/exim/bin/exim -q 15m || /bin/bash
