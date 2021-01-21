#!/bin/bash


echo "inject ${EXIM_USER}:${EXIM_GROUP} as default user"
echo "I am $(id -a)"

mkdir -p /var/log/exim
chown -R ${EXIM_USER}:${EXIM_GROUP} /var/log/exim


cd /etc/exim/config.d
sed -i "s/EXIM_EXTERNAL_HOSTNAME/mailout.${DOMAIN}.de/" exim.conf
sed -i "s/EXIM_LDAP_USER_FILTER/${EXIM_LDAP_USER_FILTER}/" exim.conf
sed -i "s/EXIM_LOCAL_DOMAINS/${EXIM_LOCAL_DOMAINS}/" exim.conf
sed -i "s/LDAP_BASE/${LDAP_BASE}/" exim.conf
sed -i "s/LDAP_PASSWORD/${LDAP_PASSWORD}/" exim.conf
sed -i "s/LDAP_USER/${LDAP_USER}/" exim.conf
sed -i "s/LDAP_HOSTS/${LDAP_HOSTS}/" exim.conf
sed -i "s/EXIM_INT_MAILOUT_LDAP_AUTH/${EXIM_INT_MAILOUT_LDAP_AUTH}/" exim.conf


set -e
# now we'd execute exim...
/usr/exim/bin/exim -bd -q 15m -C /etc/exim/config.d/exim.conf
# tail -f /var/log/exim/*g
