# docker-dovecot
lightweight alpine based dockerized dovecot, exim, rspamd environment

In order to achieve scalabality the setup will be split accross these servers:

    1 MX server, where most of the security features sit (exim-external)
    1 SMTP relay, to allow users to send mails to the outside world (exim-internal)
    1 Mailstore dovecot server, where the mailbox sits (imap)
    1 RSPAM server. Also hosts clamav. If needed, you can add other, better virus scanners here.
    1 redis server (for rspam and others)

We expect users to login via their complete email address. Two conditions must be met:
- must be memberOf the specified LDAP_group that entitles him to use mail at allowed
- the user must be found by either the mail address or an gosaMailAlternateAddress (fusiondirectory specific, you might use other tokens)

## standard config Files
see the directory install/
some of the files will be modified using below ARGS or values in .env

## Ports

| service | Port in container| comments |
| -------------- | ---------: | --------|
| imap         | 1143  | 143 in docker-compose |
| lmtp in      | 2525  | only internal, from mail srv |
| imaps        | 1993  | 993 in docker-compose |
| managesieve  | 4190  | 4190 in compose |
| exim-external  | 1025  | 25 in compose |
| exim-external  | 1587  | 587 in compose |
| exim-external  | 1465  | 465 in compose (tls on connect) |
| exim-ext-mailout  | 1025  | 2526 (instead of submission standard )in compose |
| exim-extmailout  | 1587  | 1587 in compose |
| exim-ext-mailout  | 1465  | 1465 in compose (tls on connect) |

## addresses
These are the addresses used in the services network. They shouldn't be seen elsewhere. We define them in the .env file.
| address | host| name in .env |
| -------------- | ---------: | --------|
| 172.20.0.4 | redis  | REDIS_IP |
| 172.20.0.5 | imap  | IMAP_IP |
| 172.20.0.3 | exim-external | EXIM_EXTERNAL_IP |
| 172.20.0.6 | rspam  | RSPAM_IP (listening here) |
| 172.20.0.7 | clam  | CLAMAV_IP (listening here) |
| 172.20.0.8 | exim-ext-mailout  | EXIM_EXT_MAILOUT_IP (listening here) |

## volumes
for persistent data
| volume | mountpoint| comments |
| -------------- | ---------: | --------|
| /data/$DOMAIN/vmail | /var/vmail  | imap, rw |
| /data/$DOMAIN/redis | /var/vmail  | imap, rw |

## ssl
see the secrets section of docker-compose.yaml.
## logging
we log to /dev/stderr.

## Passwords and users in .env file
| placeholder | container| comments |
| -------------- | ---------: | --------|
| REDIS_PASSWORD | redis, rspam | access to REDIS via this password |
| LDAP_PASSWORD | dovecot, exim  | admin readonly access to ldap |

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

## redis
### databases
| database | user | comments |
| -------------- | --------- | --------|
| 7 | rspamd |  |  

## rspamd
If you want to use the console, don't forget to set  RSPAMD_enable_password, RSPAMD_password

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

## testing dovecot
see https://wiki.dovecot.org/TestInstallation
