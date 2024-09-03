#!/bin/bash

cd /etc/exim/config.d
sed -i "s/EXIM_EXTERNAL_HOSTNAME/mailout.${DOMAIN}.de/" exim.conf
sed -i "s/EXIM_RELAY_HOSTS/${EXIM_RELAY_HOSTS}/" exim.conf
sed -i "s/EXIM_WHITELIST_NET/${EXIM_WHITELIST_NET}/" exim.conf
sed -i "s/EXIM_QUALIFIED_DOMAIN/${DOMAIN}.de/" exim.conf
sed -i "s/EXIM_DKIM_SELECTOR/${EXIM_DKIM_SELECTOR}/" exim.conf
sed -i "s/EXIM_DKIM_DOMAIN/${DOMAIN}.de/" exim.conf
sed -i "s/EXIM_INT_MM3_DOMAINS/${MM3_DOMAINS}/" exim.conf

sed -i "s/EXIM_EXT_MSACCOUNT/${EXIM_EXT_MSACCOUNT}/" exim.conf
sed -i "s/EXIM_EXT_PW/${EXIM_EXT_PW}/" exim.conf



set -e

/usr/exim/bin/exim -bd -q 15m  -C /etc/exim/config.d/exim.conf
