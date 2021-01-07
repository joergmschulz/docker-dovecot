FROM alpine:edge
LABEL maintainer="js@faudin.de"

ARG CLAMAV_gid
ARG CLAMAV_GROUP
ARG CLAMAV_USER
ARG CLAMAV_uid
# ARG CLAMAV_PASSWORD

RUN  addgroup -S -g ${CLAMAV_gid} $CLAMAV_GROUP || export CLAMAV_GROUP=root  && \
     adduser -S -D -H -u $CLAMAV_uid -G $CLAMAV_GROUP -g "CLAMAV user" ${CLAMAV_USER} && \
     apk add --no-cache bash clamav rsyslog wget clamav-libunrar

COPY conf /etc/clamav
COPY entrypoint.sh /usr/local/bin
# COPY check.sh /

RUN mkdir /var/run/clamav && \
    chown ${CLAMAV_USER}:$CLAMAV_GROUP  /var/run/clamav && \
    chmod 750 /var/run/clamav && \
    chown -R ${CLAMAV_USER}:$CLAMAV_GROUP /etc/clamav && \
    chmod +x /usr/local/bin/entrypoint.sh
    # check.sh

EXPOSE 3310/tcp

USER clamav
entrypoint /usr/local/bin/entrypoint.sh
# CMD ["/bootstrap.sh"]
