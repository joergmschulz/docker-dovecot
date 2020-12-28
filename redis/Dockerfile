FROM redis:alpine

ARG redis_gid
ARG REDIS_GROUP
ARG REDIS_USER
ARG redis_uid

ARG REDIS_IP=0.0.0.0
ARG REDIS_PASSWORD
# ENV REDIS_PASSWORD=TakeItFromDotEnv

# RUN   addgroup -S -g ${redis_gid} redis || export REDIS_GROUP=root  && \
#       adduser -S -D -H -u $redis_uid -G $REDIS_GROUP -g "Redis user" ${REDIS_USER} && \


RUN mkdir -p /usr/local/etc/redis && \
printf "bind ${REDIS_IP}\n\
save 900 1\n\
save 300 10\n\
save 60 10000\n\
protected-mode yes\n\
requirepass ${REDIS_PASSWORD}\n\
port 6379\n"\
> /usr/local/etc/redis/redis.conf

USER redis
CMD ["/usr/local/bin/redis-server",  "/usr/local/etc/redis/redis.conf"]
