# docker-dovecot
lightweight alpine (dovecot) and bullseye-slim (exim) based dockerized dovecot, exim, rspamd, clamav environment; some self-compiled, some from stock.

install using examples/sampleDotEnv


In order to achieve scalabality the setup will be split accross these servers:

## services and addresses
These are the addresses used in the services network. They shouldn't be seen elsewhere. We define them in the .env file.

| address | host| name in .env | location (at entity or global) | description |
| -------------- | ---------: | -------- |-------- | ----------------- |
| 172.20.0.4 | redis  | REDIS_IP | local/global | key/value storage for all local services like rspam, nextcloud |
| 172.20.0.5 | imap  | IMAP_IP | local | imap server for organization members. backend for Sogo and eventually contacted from outside. currently dovecot |
| 172.20.0.3 | exim-external | EXIM_EXTERNAL_IP | location | locally receives mail for organization members if they are listed in the appropriate LDAP group |
| 172.20.0.6 | rspam  | RSPAM_IP (listening here) | global | global spam / virus checker, currently global, might be changed to local |
| 172.20.0.7 | clam  | CLAMAV_IP (listening here) | global | global spam / virus checker, currently global, might be changed to local |
| 172.20.0.8 | exim-ext-mailout  | EXIM_EXT_MAILOUT_IP (listening here) | global | smarthost for all: sends out emails to the world, local smtp hosts and all services can connect here for mail delivery. Will be spamchecked, DKIM signed and queued. you must define an extra smarthost.${DOMAIN}.de that CAN be different from this one here. should also connect to mailman3|
| 172.20.0.9 | exim-int-mailout  | EXIM_INT_MAILOUT_IP (listening here) | local | local users and services will connect here to send out their mail. connects to smarthost. Users must be member of LDAP group ${EXIM_PUBLIC_LDAP_USER_FILTER} to send mails to non-local hosts. Will be spamchecked, DKIM signed and queued. |

We expect users to login via their complete email address. Two conditions must be met:
- must be memberOf the specified LDAP_group that entitles him to use mail at allowed
- the user must be found by either the mail address or an gosaMailAlternateAddress (fusiondirectory specific, you might use other tokens)

## standard config Files
see the directory install/
some of the files will be modified using below ARGS or values in .env - see the entrypoint scripts.


## startup
git pull docker-dovecot master  && vi .env && docker-compose down && docker-compose build && docker-compose up -d

## Ports

| service | Port in container| external | comments |
| -------------- | ---------: | --------- | --------|
| imap         | 1143  | 143 in  | docker-compose |
| lmtp in      | 2525  |  | only internal, from mail srv |
| imaps        | 1993  | 993  | in docker-compose |
| managesieve  | 4190  | 4190  | in compose |
| exim-external  | 1025  | 25  | in compose |
| exim-external  | 1587  | 587  | in compose |
| exim-external  | 1465  | 465  | in compose (tls on connect) |
| exim-ext-mailout  | 1025  | 2526  | (instead of submission standard )in compose |
| exim-extmailout  | 1587  | 1587  | in compose |
| exim-ext-mailout  | 1465  | 1465  | in compose (tls on connect) |
| exim-int-mailout  | 1587  | 2587  | in compose (this is the port the users have to use.) |
| REDIS_PORT       | 6379  |  | set in .env |



## volumes
for persistent data
you might need to create and chown/chmod the data directories referenced in .env:


| volume | mountpoint| comments |
| -------------- | ---------: | --------|
| /data/$DOMAIN/vmail | /var/vmail  | imap, rw |
| /data/$DOMAIN/redis | /var/vmail  | imap, rw |
| ${CLAMAVLIB:-/data/clamav} | /var/lib/clamav  | clamav . To be tweaked in .env file |
|

## ssl
see the secrets section of docker-compose.yaml.
## logging
we log to /dev/stderr.

## Passwords and users in .env file
| placeholder | container| comments |
| -------------- | ---------: | --------|
| REDIS_PASSWORD | redis, rspam | access to REDIS via this password |
| LDAP_PASSWORD | dovecot, exim  | admin readonly access to ldap |

## passwd.client
(tbd) if you need to use specific relays to hotmail, you need to populate the exim-ext-mailout/.passwd.client file.
for the time being, we use EXIM_EXT_MSACCOUNT : EXIM_EXT_PW

## build time parameters
as always, documentation lags behind. Ask questions, answers will be here.

# runtime parameters
## LDAP
We expect a TLS connection to your ldap hosts.
Set these values in your .env file. Watch up that you escape the \& with \\& until we find a better way to replace the parameters than using sed

| Parameter | sample | comments |
| -------------- | --------- | --------|
| LDAP_HOSTS | ldap1 ldap2 ldap3 | Space separated list of LDAP hosts to use. host:port is allowed too. |
| LDAP_PASSWORD  | topsecret | |
| LDAP_USER | cn=somebody,dc=yourDomain,dc=de |  |
| LDAP_BASE | ``ou=People,dc=yourDomain,dc=de`` |  |
| LDAP_USER_FILTER, LDAP_PASS_FILTER, LDAP_ITERATE_FILTER| use your convenient LDAP filters here | technically select approved users by LDAP entities |
| LDAP_IP  | 10.100.1.23 | IP address of your LDAP server |
| DOMAIN  | faudin | the domain part of your hosts. The imap host will be composed as imap.$DOMAIN.de, smtp.$DOMAIN.de. Adjust your DNS. The external mail host will be named mail.${DOMAIN}.de |
| EXIM_INT_MAILOUT_LDAP_AUTH | ldap:///ou=People,dc=elternserver,dc=de??sub?(mail=${quote_ldap:$auth1}) | these people can login to the local mailout server in order to send mail. |

## redis
### databases
| database | user | comments |
| -------------- | --------- | --------|
| 7 | rspamd |  |  

enable or disable REDIS_PRODECTED_MODE in .env (for future use)
Currently, you must comment the redis port stanza in docker-compose.yaml if you want to NOT expose redis.
You can run multiple redis on one host if you set the REDIS_PORT to something different.

## rspamd
If you want to use the console, don't forget to set  RSPAMD_enable_password, RSPAMD_password
for your local white/blacklists, you'll need the /var/lib/rspamd/maps.d directory

## ClamAV
currently stolen from https://github.com/mko-x/docker-clamav/blob/master/docker-compose.yml

## exim
### mail acceptance
EXIM will accept mails to EXIM_LOCAL_DOMAINS as listed in .env
In order to NOT pass all invalid users to dovecot, we'll look up the validity of the users via LDAP. Valid users must be memberOf the group localMail.

Currently all mails to all accepted domains are delivered to the imap server imap.$DOMAIN.de. We might find a way to configure this in LDAP.

## exim-ext-mailout
This is responsible for mailing out. only hosts in $EXIM_LOCAL_DOMAINS and hosts from mail network can send out messages.
EXIM_RELAY_HOSTS : EXIM_WHITELIST_NET can send out messages.

DKIM see also https://exim.org/exim-html-current/doc/html/spec_html/ch-dkim_spf_and_dmarc.html ;
```
openssl genrsa -out dkim_rsa.private 2048
openssl rsa -in dkim_rsa.private -out /dev/stdout -pubout -outform PEM
```
save the result as 20210111._domainkey.${DOMAIN}.de with the content k=rsa;p=[output of 2nd command]
## IMAP replication
(WIP)
if you define the IMAP_REPLICA_* parameters in your .env, replication should be possible.

# License
This portion of the project has been made by js@jslz.de using inspiration from MIT/X11 licensed github content.
As some other portions of the project have been derived from GPLed code, we need to be on the safe side and GPL it all.
# dnsmasq
as exim insists on dns lookups for al hostnames and ignores resolv.conf, we install dnsmasq.
the config file is generated automatically. To add hosts, use dnsmasq/local_hosts or the extra_hosts in docker-compose.yml.

# build side notes
## exim
for exim, see http://exim.org/exim-html-current/doc/html/spec_html/ch-building_and_installing_exim.html and https://registry.hub.docker.com/r/itherz/exim4/dockerfile
all build parameters are set in the Local/makefile
see also https://www.howtoforge.com/setting-up-a-mail-server-using-exim4-clamav-dovecot-spamassassin-and-many-more-on-debian-p2
### exim makefile
dbm  = gdbm, see Local/makefile
SPOOL_DIRECTORY=/var/spool/exim; this is not persistent
Watch out for entrypoint.sh - this one builds the exim config.
logging goes to the (mounted? ) directory /var/log/exim/. The exicyclog script isn't run by default; you have to set up a cron job for it if you want it.
## dovecot
smtp mailout possible when https://serverfault.com/questions/630291/sieve-redirect-to-foreign-email-gets-relay-access-denied submission_host is set correctly
### sieve
individual sieve configurations are possible. Global defaults are stored in etc/dovecot/sieve.d/
#### a word on autolearn
sievec is used for auto-learning. You need the rspamd clear text password in a docker secret which should be available locally as .RSPAM_Clear_password file.

### version of dovecot
see the sample .env file. Version 16 is the most current, but your mileage may vary. See the dovecot  mailing list or revert to .15.

### testing dovecot
see https://wiki.dovecot.org/TestInstallation

${IMAP_AUTH_VERBOSE} ${IMAP_MAIL_DEBUG} can help debug dovecot.

### mailman3
We're beginning to integrate mailman.
exim-int-mailout will need a mailman volume and some configs. See example .env!

We don't currently plan to add a way to leave out mailman.

### firewall
if you're using UFW, you'll see docker opening ports to the world.
You don't want that.
So, add /etc/ufw/after.rules :

(todo: add the IPs of the services, so you'll only have the correct services listening)

````
# BEGIN UFW AND DOCKER
# *filter
:ufw-user-forward - [0:0]
:ufw-docker-logging-deny - [0:0]
:DOCKER-USER - [0:0]
-A DOCKER-USER -j ufw-user-forward

-A DOCKER-USER -j RETURN -s 10.0.0.0/8
-A DOCKER-USER -j RETURN -s 172.16.0.0/12
-A DOCKER-USER -j RETURN -s 192.168.0.0/16

-A DOCKER-USER -p udp -m udp --sport 53 --dport 1024:65535 -j RETURN
# allow all ports your installation wants to expose
-A DOCKER-USER -p tcp --dport 25 -j RETURN
-A DOCKER-USER -p tcp --dport 1025 -j RETURN
-A DOCKER-USER -p tcp --dport 1465 -j RETURN
-A DOCKER-USER -p tcp --dport 1587 -j RETURN
-A DOCKER-USER -p tcp --dport 1143 -j RETURN
-A DOCKER-USER -p tcp --dport 4190 -j RETURN
-A DOCKER-USER -p tcp --dport 143 -j RETURN
-A DOCKER-USER -p tcp --dport 80 -j RETURN
-A DOCKER-USER -p tcp --dport 587 -j RETURN
-A DOCKER-USER -p tcp --dport 443 -j RETURN
-A DOCKER-USER -p tcp --dport 8443 -j RETURN
-A DOCKER-USER -p tcp --dport 9980 -j RETURN
-A DOCKER-USER -p tcp --dport 993 -j RETURN

-A DOCKER-USER -j ufw-docker-logging-deny -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 192.168.0.0/16
-A DOCKER-USER -j ufw-docker-logging-deny -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 10.0.0.0/8
-A DOCKER-USER -j ufw-docker-logging-deny -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 172.16.0.0/12
-A DOCKER-USER -j ufw-docker-logging-deny -p udp -m udp --dport 0:32767 -d 192.168.0.0/16
-A DOCKER-USER -j ufw-docker-logging-deny -p udp -m udp --dport 0:32767 -d 10.0.0.0/8
-A DOCKER-USER -j ufw-docker-logging-deny -p udp -m udp --dport 0:32767 -d 172.16.0.0/12

-A DOCKER-USER -j RETURN

-A ufw-docker-logging-deny -m limit --limit 3/min --limit-burst 10 -j LOG --log-prefix "[UFW DOCKER BLOCK] "
-A ufw-docker-logging-deny -j DROP

COMMIT
# END UFW AND DOCKER

````

## MM3
if needed, this image contains a mailman3 environment. External dependency: postgres database.
see example dot env file.

Define HAVE_MM3.
set all MM3 variables as appropriate.

## special firewall rules
sudo ufw allow from 172.0.0.0/8 to mailout.${domain}.de port 1587
