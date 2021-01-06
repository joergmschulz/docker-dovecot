#!/bin/sh
set -e

cd /etc/rspamd/local.d
sed -i "s/REDIS_PASSWORD/${REDIS_PASSWORD}/" redis.conf
sed -i "s/RSPAM_REDIS_DB/${RSPAM_REDIS_DB}/" redis.conf

printf "enable_password = \"${RSPAM_enable_password}\";\n\
password = \"${RSPAM_password}\";\n\
bind_socket = \"0.0.0.0:11334\";\n" > worker-controller.inc

sed -i "s/RSPAM_IP/${RSPAM_IP}/" worker-normal.inc



( freshclam -u ${RSPAM_USER} && \
clamd && \
rspamd -f -u ${RSPAM_USER} -g $RSPAM_GROUP ) || exec "$@"
