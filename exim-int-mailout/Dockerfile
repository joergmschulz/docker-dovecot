FROM debian:bullseye-slim

ARG EXIM_GID
ARG EXIM_GROUP
ARG EXIM_USER
ARG EXIM_UID

ARG EXIM_IP=0.0.0.0

ENV EXIM_PORTS="1025 : 1465 : 1587"
ENV EXIM_TLS_ON_CONNECT_PORTS=1465

RUN set -x && \
    apt-get -y update \
    && apt-get -y upgrade \
    && apt-get install -y libldap-2.4-2 libspf2-2 && \
    addgroup --system --gid ${EXIM_GID} ${EXIM_GROUP} || export EXIM_GROUP=root  && \
    adduser --disabled-login --no-create-home  --uid $EXIM_UID --ingroup $EXIM_GROUP --gecos EXIM $EXIM_USER

COPY --from=joergschulz/exim  /usr/exim /usr/exim

ARG ACCESS_FIX="/etc/exim/config.d /var/log/exim /var/spool/exim"
RUN for d in ${ACCESS_FIX} ; do mkdir -p $d ; done && \
    chown -R ${EXIM_USER}:${EXIM_GROUP} ${ACCESS_FIX} && \
    find ${ACCESS_FIX} -type d -exec chmod g+wx {} \; && \
    ln -sf /dev/stdout /var/log/exim/main.log && \
    ln -sf /dev/stderr /var/log/exim/panic.log && \
    ln -sf /dev/stderr /var/log/exim/reject.log && \
    ## this will need more investigation
    echo "TLS_REQCERT never" >> /etc/ldap/ldap.conf

ADD exim.conf /etc/exim/config.d/exim.conf


COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
USER ${EXIM_USER}
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
