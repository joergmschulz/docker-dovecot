#!/bin/bash

cd /etc/exim/config.d
sed -i "s/EXIM_EXTERNAL_HOSTNAME/mailout.${DOMAIN}.de/" exim.conf
sed -i "s/EXIM_RELAY_HOSTS/${EXIM_RELAY_HOSTS}/" exim.conf
sed -i "s/EXIM_WHITELIST_NET/${EXIM_WHITELIST_NET}/" exim.conf
sed -i "s/EXIM_QUALIFIED_DOMAIN/${DOMAIN}.de/" exim.conf
sed -i "s/EXIM_DKIM_SELECTOR/${EXIM_DKIM_SELECTOR}/" exim.conf
sed -i "s/EXIM_DKIM_DOMAIN/${DOMAIN}.de/" exim.conf

#  :
# sed -i "s/IMAP_DOMAIN/${DOMAIN}/" exim.conf - not possible - lmtp only from internal network




# echo ${EXIM_PORTS} > EXIM_PORTS
# echo ${SUBMISSION_PORT} > SUBMISSION_PORT
# echo ${EXIM_TLS_ON_CONNECT_PORTS}>EXIM_TLS_ON_CONNECT_PORTS
set -e
# now we'd execute exim...
/usr/exim/bin/exim -bd -q 15m -C /etc/exim/config.d/exim.conf
