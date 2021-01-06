FROM alpine:edge

ARG RSPAM_gid
ARG RSPAM_GROUP
ARG RSPAM_USER
ARG RSPAM_uid
ARG RSPAM_PASSWORD
ARG RSPAM_IP=0.0.0.0


# ARG CLAMAV_gid
# ARG CLAMAV_GROUP
# ARG CLAMAV_USER
# ARG CLAMAV_uid
# ARG CLAMAV_PASSWORD

ENV RSPAM_enable_password=TakeItFromDotEnv
ENV RSPAM_password=TakeItFromDotEnv
ENV RSPAM_REDIS_DB=7


RUN set -eux && \
        addgroup -S -g ${RSPAM_gid} $RSPAM_GROUP || export RSPAM_GROUP=root  && \
        adduser -S -D -H -u $RSPAM_uid -G $RSPAM_GROUP -g "RSPAM user" ${RSPAM_USER} && \
        # addgroup -S -g ${CLAMAV_gid} $CLAMAV_GROUP || export CLAMAV_GROUP=root  && \
        # adduser -S -D -H -u $CLAMAV_uid -G $CLAMAV_GROUP -g "CLAMAV user" ${CLAMAV_USER} && \
        apk add --no-cache --virtual \
            tzdata \
            rspamd \
            clamav \
            clamav-libunrar

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ADD etc/rspamd /etc/rspamd

ARG ACCESS_FIX="/var/log/rspamd /run/rspamd /var/lib/rspamd /etc/rspamd /var/lib/clamav /run/clamav /var/log/clamav"
RUN for d in ${ACCESS_FIX} ; do mkdir -p $d ; done ; \
    chown -R ${RSPAM_USER}:${RSPAM_GROUP} ${ACCESS_FIX} && \
    find ${ACCESS_FIX} -type d -exec chmod g+wx {} \;

# ARG ACCESS_FIX="/var/lib/clamav /run/clamav /var/log/clamav"
# RUN for d in ${ACCESS_FIX} ; do mkdir -p $d ; done && \
#    chown -R ${CLAMAV_USER}:${CLAMAV_GROUP} ${ACCESS_FIX} && \
#     find ${ACCESS_FIX} -type d -exec chmod g+wx {} \;
RUN chmod +x /usr/local/bin/entrypoint.sh
USER ${RSPAM_USER}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
