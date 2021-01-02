#!/bin/bash


echo "inject ${EXIM_USER}:${EXIM_GROUP} as default user"
echo "I am $(id -a)"

mkdir -p /var/log/exim
chown -R ${EXIM_USER}:${EXIM_GROUP} /var/log/exim


cd /etc/exim/config.d
sed -i "s/EXIM_EXTERNAL_HOSTNAME/mail.${DOMAIN}.de/" exim.conf
sed -i "s/EXIM_LOCAL_DOMAINS/${DOMAIN}.de/" exim.conf

# echo ${EXIM_PORTS} > EXIM_PORTS
# echo ${SUBMISSION_PORT} > SUBMISSION_PORT
# echo ${EXIM_TLS_ON_CONNECT_PORTS}>EXIM_TLS_ON_CONNECT_PORTS
set -e
# now we'd execute exim...
/usr/exim/bin/exim -bd -q 15m -C /etc/exim/config.d/exim.conf
# tail -f /var/log/exim/*g
