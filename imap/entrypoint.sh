#!/bin/sh

me=$(id -un)
mygroup=$(id -gn)

echo "inject ${me} as default user"
sed -i "s/default_internal_user.*/default_internal_user = ${me}/" /etc/dovecot/dovecot.conf
sed -i "s/default_login_user.*/default_login_user = ${me}/" /etc/dovecot/dovecot.conf
sed -i "s/default_internal_group.*/default_internal_group = ${mygroup}/" /etc/dovecot/dovecot.conf
sed -i "s/VMAIL_GROUP/${mygroup}/" /etc/dovecot/dovecot.conf
sed -i "s/LDAP_PASSWORD/${LDAP_PASSWORD}/" /etc/dovecot/dovecot-ldap.conf.ext
sed -i "s/LDAP_HOSTS/${LDAP_HOSTS}/" /etc/dovecot/dovecot-ldap.conf.ext
sed -i "s/LDAP_BASE/${LDAP_BASE}/" /etc/dovecot/dovecot-ldap.conf.ext
sed -i "s/LDAP_USER_FILTER/${LDAP_USER_FILTER}/" /etc/dovecot/dovecot-ldap.conf.ext
sed -i "s/LDAP_PASS_FILTER/${LDAP_PASS_FILTER}/" /etc/dovecot/dovecot-ldap.conf.ext
sed -i "s/LDAP_ITERATE_FILTER/${LDAP_ITERATE_FILTER}/" /etc/dovecot/dovecot-ldap.conf.ext
sed -i "s/LDAP_USER/${LDAP_USER}/" /etc/dovecot/dovecot-ldap.conf.ext



echo "start dovecot"
# exec /bin/sh
exec /usr/local/dovecot/sbin/dovecot -F
