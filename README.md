# docker-dovecot
lightweight alpine based dockerized dovecot
## Ports

| service | Port in container|
| -------------- | ---------: |
| imap         | 1143  |
| smtp in      | 2525  |
| lmtp         | 1024  |
| submission   | 1587  |
| imaps        | 1993  |
| managesieve  | 4190  |

## addresses

## runtime parameters
### LDAP
Set these values in your .env file
LDAP_HOSTS
LDAP_PASSWORD

