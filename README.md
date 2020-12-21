# docker-dovecot
lightweight alpine based dockerized dovecot

## standard config Files
see the directory install/
some of the files will be modifid using below ARGS or values in .env

## Ports

| service | Port in container| comments |
| -------------- | ---------: | --------|
| imap         | 1143  | 143 in docker-compose |
| lmtp in      | 2525  | only internal, from mail srv |
| imaps        | 1993  | 993 in docker-compose |
| managesieve  | 4190  | 4190 in compose |

## addresses

## runtime parameters
### LDAP
Set these values in your .env file
| Parameter | sample | comments |
| -------------- | --------- | --------|
| LDAP_HOSTS | ldap1 ldap2 ldap3 | space separated list of LDAP hosts |
| LDAP_PASSWORD  | topsecret | |
| LDAP_USER | "cn=admin_ro,dc=elternserver,dc=de" | as long as you keep auth_bind = yes |
