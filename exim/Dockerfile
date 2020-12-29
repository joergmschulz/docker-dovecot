FROM debian:buster-slim






ARG EXIM_GID
ARG EXIM_GROUP
ARG EXIM_USER
ARG EXIM_UID

ARG EXIM_IP=0.0.0.0
# ARG EXIM_VERSION=4.94
ARG EXIM_VERSION=master

ARG EXIM_SOURCE=https://github.com/exim/exim/archive/exim-${EXIM_VERSION}.tar.gz




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
      mkdir -p /usr/src/exim/Local

# tweak this makefile. currently users are hardcoded.
ADD Local/Makefile /usr/src/exim/src/Local/

RUN set -eux; \
    cd /usr/src/exim/src && \
    make && make install && \
    rm -rf /usr/src && \
    apt-get remove -y build-essential libldap2-dev libpcre3-dev libdkim-dev && \ 
    apt-get autoremove --purge  && apt-get clean  && rm -rf /var/lib/apt/lists/*

ARG ACCESS_FIX="/var/log/ /var/spool/exim"
RUN for d in ${ACCESS_FIX} ; do mkdir -p $d ; done && \
    chown -R ${EXIM_USER}:${EXIM_GROUP} ${ACCESS_FIX} && \
    find ${ACCESS_FIX} -type d -exec chmod g+wx {} \;

USER exim
CMD ["/bin/sh"]
