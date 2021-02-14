#!/bin/sh

me=$(id -un)
mygroup=$(id -gn)

echo "inject ${me} as default user"
sed -i "s/default_internal_user.*/default_internal_user = ${me}/" /etc/dovecot/dovecot.conf
sed -i "s/IMAP_AUTH_VERBOSE/${IMAP_AUTH_VERBOSE}/" /etc/dovecot/dovecot.conf
sed -i "s/IMAP_MAIL_DEBUG/${IMAP_MAIL_DEBUG}/" /etc/dovecot/dovecot.conf
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



# enable replication if the variables are set
if !([ -n ${IMAP_REPLICA_SERVER} ])
then
  printf "service replicator {  \n\
  process_min_avail = 1  \n\
}  \n\
service aggregator {  \n\
  chroot = \n\
}  \n\
service replicator {  \n\
  unix_listener replicator-doveadm {  \n\
    mode = 0600  \n\
    user = ${me}   \n\
    group = ${mygroup} \n\
  }  \n\
}  \n\
plugin {  \n\
    replication_sync_timeout = 2  \n\
}  \n\
service doveadm {  \n\
  user = ${me}  \n\
  group = ${mygroup} \n\
  inet_listener {  \n\
    port = $IMAP_REPLICA_PORT  \n\
  }  \n\
}  \n\
doveadm_port =  $IMAP_REPLICA_PORT \n\
doveadm_password = $IMAP_REPLICA_PASSWORD  \n\
plugin {  \n\
  mail_replica = tcp:$IMAP_REPLICA_SERVER:$IMAP_REPLICA_PORT # use doveadm_port  \n\
}  \n\
service config {\n\
  unix_listener config {\n\
    user = ${me}\n\
    group = ${mygroup} \n\
  }\n\
}
  \n\
  " > /etc/dovecot/conf.d/replication.conf


fi

echo "start dovecot"
# exec /bin/sh
exec /usr/local/dovecot/sbin/dovecot -F
