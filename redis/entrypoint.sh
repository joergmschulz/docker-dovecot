#!/bin/sh


# printf "bind ${REDIS_IP}\n\
printf "save 900 1\n\
save 300 10\n\
save 60 10000\n\
protected-mode ${REDIS_PRODECTED_MODE}\n\
dir /data\n\
logfile \"\"\n\
requirepass ${REDIS_PASSWORD}\n\
port REDIS_PORT\n"\
> /usr/local/etc/redis/redis.conf

/usr/local/bin/redis-server  /usr/local/etc/redis/redis.conf || exec "$@"
