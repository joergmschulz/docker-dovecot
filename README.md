# docker-dovecot
lightweight alpine based dockerized dovecot

We expect users to login via their complete email address. Two conditions must be met:
- must be memberOf the specified LDAP_group that entitles him to use mail at allowed
- the user must be found by either the mail address or an gosaMailAlternateAddress (fusiondirectory specific, you might use other tokens)

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
## ssl
see the secrets section of docker-compose.yaml.
## logging
we log to /dev/stderr.


## runtime parameters
### LDAP
We expect a TLS connection to your ldap hosts.
Set these values in your .env file
| Parameter | sample | comments |
| -------------- | --------- | --------|
| LDAP_HOSTS | ldap1 ldap2 ldap3 | Space separated list of LDAP hosts to use. host:port is allowed too. |
| LDAP_PASSWORD  | topsecret | |
| LDAP_USER | "cn=somebody,dc=yourDomain,dc=de" |  |
| LDAP_BASE | "ou=People,dc=yourDomain,dc=de"" |  |
| LDAP_*FILTER | "((|(mail=%u)(|(gosaMailAlternateAddress=%u))))" | technically select approved users by LDAP entities |


## testing
see https://wiki.dovecot.org/TestInstallation
