FROM alpine:3.20 AS build

ARG vmail_gid
ARG VMAIL_GROUP
ARG VMAIL_USER
ARG vmail_uid
ENV LDAP_HOSTS=TakeItFromDotEnv
ENV LDAP_PASSWORD=TakeItFromDotEnv
ENV LDAP_PASS_FILTER=TakeItFromDotEnv
ENV LDAP_USER_FILTER=TakeItFromDotEnv
ENV LDAP_ITERATE_FILTER=TakeItFromDotEnv

ARG dovecot_tag
ARG dovecot_branch
ARG pigeonhole_branch
ARG pigeonhole_tag
ARG DOVECOT_PREFIX=/usr/local/dovecot
# ARG pigeonhole_branch=master




#
#  ARG ACCESS_FIX="/run/dovecot /var/run/dovecot"
#


# build options
ARG dovecot_config="--without-pam \
          --without-cdb \
          --with-zlib \
          --with-bzlib \
          --with-storages=maildir \
          --with-ldap \
          --with-ssl=openssl \
          --sysconfdir=/etc \
          --prefix=${DOVECOT_PREFIX}  \
          --with-sql=no \
          --without-sqlite \
          --without-apparmor \
          --without-mysql \
          --without-pgsql \
          --without-docs \
          --without-libcap \
          --without-sql-drivers \
          --without-mysql \
          --without-sodium \
          --without-systemd \
          --localstatedir=/var/lib/dovecot \
          --enable-experimental-mail-utf8 \
          --enable-dependency-tracking"

ARG pigeonhole_config="--with-dovecot=../dovecot --sysconfdir=/etc --prefix=${DOVECOT_PREFIX} --localstatedir=/var/lib/dovecot \
	--with-managesieve=yes \
        --with-ldap=no"

RUN    addgroup -S -g ${vmail_gid} vmail || export VMAIL_GROUP=root  && adduser -S -D -H -u $vmail_uid -G $VMAIL_GROUP -g "Dovecot Vmail" ${VMAIL_USER} && \
    \
    set -x && \
    apk update && \
    apk upgrade -U -a && \
    # libressl-dev \
    apk add --no-cache --virtual .build-deps \
        bzip2-dev lz4-dev xz-dev zlib-dev \
        runc \
        postgresql-dev mariadb-dev sqlite-dev \
        openldap-dev \
        heimdal-dev \
        gnu-libiconv \
        linux-headers git automake cmake \
            gawk \
            g++ \
            make \
            openldap-dev zlib-dev bzip2-dev autoconf libtool libc-dev gettext gcc bison flex gnutls-dev gettext-dev rpcgen openssl-dev file && \
    mkdir -p /opt/dovecot && cd /opt/dovecot && \
    git init . && \
    git remote add -t ${dovecot_branch} origin https://github.com/dovecot/core && \
    git fetch --depth=1 && git checkout ${dovecot_tag} && \
    ./autogen.sh && \
    mkdir -p ${DOVECOT_PREFIX} && \
    PANDOC=false  ./configure ${dovecot_config} ### &&  \
RUN set -x && \
    cd /opt/dovecot && \
    make -s -j$(nproc)
RUN set -x && \
    cd /opt/dovecot && \
    make install && \
    mkdir /opt/pigeonhole/ && \
    cd /opt/pigeonhole && \
    git init . && git remote add -t ${pigeonhole_branch} origin https://github.com/dovecot/pigeonhole.git && \
    git fetch --depth=1 && git checkout ${pigeonhole_tag} && ./autogen.sh && \
    ./configure ${pigeonhole_config} && \
    make -s -j$(nproc) && make install && \
### Setup Container for Dovecot
    rm -rf /etc/dovecot/* && \
    mkdir -p /var/lib/dovecot && \
    # mkdir -p /var/log/dovecot && \
    chown -R ${VMAIL_USER}:${VMAIL_GROUP} /var/lib/dovecot/  ${DOVECOT_PREFIX}  && \
    \
### Cleanup
## this should be removed on prod
    ## apk add openldap-clients && \
    rm -rf /var/cache/apk/* && \
    rm -rf /opt/dovecot /opt/pigeonhole

### Networking Configuration
EXPOSE 1143 2525 1024 1587 1993 4190


FROM alpine:3.20

ARG vmail_gid
ARG VMAIL_GROUP
ARG VMAIL_USER
ARG vmail_uid
ENV LDAP_HOSTS=TakeItFromDotEnv
ENV LDAP_PASSWORD=TakeItFromDotEnv
ENV LDAP_PASS_FILTER=TakeItFromDotEnv
ENV LDAP_USER_FILTER=TakeItFromDotEnv
ENV LDAP_ITERATE_FILTER=TakeItFromDotEnv
ENV SMTPHOST=exim-int-mailout:1587

COPY --from=build /usr/local/dovecot /usr/local/dovecot
ADD install /

RUN apk update && \
    apk upgrade -U -a && \
    apk add openldap-clients  \
    zlib \
    bzip2 \
    lz4 \
    rspamd-client \
    bzip2-dev lz4-dev xz-dev zlib-dev \
    openldap && \
    addgroup -S -g ${vmail_gid} vmail || export VMAIL_GROUP=root  && adduser -S -D -H -u $vmail_uid -G $VMAIL_GROUP -g "Dovecot Vmail" ${VMAIL_USER} && \
    # mkdir -p /var/log/dovecot && \
    mkdir -p /var/lib/dovecot && \
    chown -R ${VMAIL_USER}:${VMAIL_GROUP} /var/lib/dovecot/  ${DOVECOT_PREFIX} && \
    ( cd /etc/dovecot && \
    chown -R ${VMAIL_USER}:${VMAIL_GROUP} /etc/dovecot && \
    test -f dh.pem || openssl dhparam 4096 > dh.pem ) && \
    chmod g+r /etc/dovecot/dovecot-ldap.conf.ext && \
    chmod +x /etc/dovecot/sieve/*sh && \
    chown -R ${VMAIL_USER}:${VMAIL_GROUP} /etc/dovecot && \
    chmod +x /usr/local/scripts/*


COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
USER ${VMAIL_USER}
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# CMD ["dovecot", "-F"]

# CMD ["/bin/sh"]
