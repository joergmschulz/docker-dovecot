# docker-dovecot
lightweight alpine based dockerized dovecot
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
LDAP_HOSTS
LDAP_PASSWORD
LDAP_USER

