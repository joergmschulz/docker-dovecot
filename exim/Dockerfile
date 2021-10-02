FROM debian:bullseye-slim as build

ARG EXIM_GID
ARG EXIM_GROUP
ARG EXIM_USER
ARG EXIM_UID

ARG EXIM_IP=0.0.0.0
ARG EXIM_VERSION=4.94
# ARG EXIM_VERSION=master

ARG EXIM_SOURCE=https://github.com/exim/exim/archive/exim-${EXIM_VERSION}.tar.gz

ENV EXIM_PORTS="1025 : 1465 : 1587"
ENV EXIM_TLS_ON_CONNECT_PORTS=1465
# ENV DOMAIN=TakeItFromDotEnv


RUN set -x && \
    addgroup --system --gid ${EXIM_GID} ${EXIM_GROUP} || export EXIM_GROUP=root  && \
    adduser --disabled-login --no-create-home  --uid $EXIM_UID --ingroup $EXIM_GROUP --gecos EXIM $EXIM_USER && \
    apt-get -y update \
    && apt-get -y upgrade \
    && apt-get install -y libldap2-dev tzdata  \
      git libpcre3-dev build-essential libdb-dev  \
      libopendmarc-dev  libspf2-dev  \
      libldap2-dev libldap-common \
      libdkim-dev  \
      libssl-dev  \
      libidn11-dev && \
    dpkg-reconfigure -f noninteractive tzdata



RUN set -eux; \
      mkdir -p /usr/src && cd /usr/src && \
      git clone https://github.com/exim/exim -b $EXIM_VERSION exim && \
      # echo "$EXIM_DOWNLOAD_SHA *exim.tar.gz" | sha256sum -c -; \ TBD!
      mkdir -p /usr/src/exim/Local && \
      mkdir -p /etc/exim


ADD Local/Makefile /usr/src/exim/src/Local/
RUN set -eux; \
    cd /usr/src/exim/src && \
    sed -i "s/EXIM_LOCAL_USER/${EXIM_USER}/" Local/Makefile && \
    sed -i "s/EXIM_LOCAL_GROUP/${EXIM_GROUP}/" Local/Makefile && \
    make && make install && \
    rm -rf /usr/src && \
    apt-get remove -y build-essential  libpcre3-dev libdkim-dev git && \
    apt-get -y autoremove --purge  && apt-get clean  && rm -rf /var/lib/apt/lists/*

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
    && apt-get install -y libldap-2.4-2 libspf2-2 ca-certificates && \
    addgroup --system --gid ${EXIM_GID} ${EXIM_GROUP} || export EXIM_GROUP=root  && \
    adduser --disabled-login --no-create-home  --uid $EXIM_UID --ingroup $EXIM_GROUP --gecos EXIM $EXIM_USER
COPY --from=build /usr/exim /usr/exim


ARG ACCESS_FIX="/etc/exim/config.d /var/log/exim /var/spool/exim"
# fix access, log to stderr
RUN for d in ${ACCESS_FIX} ; do mkdir -p $d ; done && \
    chown -R ${EXIM_USER}:${EXIM_GROUP} ${ACCESS_FIX} && \
    find ${ACCESS_FIX} -type d -exec chmod g+wx {} \;  && \
    # ln -sf /dev/stdout /var/log/exim/main.log && \
    #ln -sf /dev/stderr /var/log/exim/panic.log && \
    #ln -sf /dev/stderr /var/log/exim/reject.log && \
## this will need more investigation
    echo "TLS_REQCERT never" >> /etc/ldap/ldap.conf && \
    printf "root: postmaster@${DOMAIN}.de" > /etc/aliases
ADD exim.conf /etc/exim/config.d/exim.conf


COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
USER ${EXIM_USER}
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]


CMD ["/bin/bash"]
