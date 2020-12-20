FROM alpine:edge

ARG vmail_gid
ARG VMAIL_GROUP
ARG VMAIL_USER
ARG vmail_uid

ARG dovecot_branch=release-2.3.11
ARG DOVECOT_PREFIX=/usr/local/dovecot
# 
#  ARG ACCESS_FIX="/run/dovecot /var/run/dovecot"
# 


# build options
ARG dovecot_config="-enable-dependency-tracking \
          --without-pam \
          --without-cdb \
          --with-zlib \
          --with-bzlib \
          --with-gc \
          --with-storages=maildir \
          --with-ldap \
          --without-solr \
          --with-ssl=openssl \
          --sysconfdir=/etc \
          --prefix=${DOVECOT_PREFIX}  \
          --with-sql=no \
          --without-sqlite \
          --without-mysql \
          --without-pgsql \
          --without-docs \
          --without-sql-drivers \
          --without-mysql \
          --localstatedir=/var/lib/dovecot"

ARG pigeonhole_config="--with-dovecot=../dovecot --sysconfdir=/etc --prefix=${DOVECOT_PREFIX} --localstatedir=/var/lib/dovecot \
	--with-managesieve=yes \
        --with-ldap=no"
### Create Vmail User
    # groupadd -f -g $vmail_gid vmail && \
    # adduser -S -D -H -u $vmail_uid -G vmail -g "Dovecot Vmail" ${VMAIL_USER} && \
RUN    addgroup -S -g 0 vmail || export VMAIL_GROUP=root  && adduser -S -D -H -u $vmail_uid -G $VMAIL_GROUP -g "Dovecot Vmail" ${VMAIL_USER} && \
    \
    set -x && \
    apk update && \
    apk upgrade && \
    apk add git automake make openldap-dev zlib-dev bzip2-dev autoconf libtool libc-dev gettext gcc bison flex gnutls-dev gettext-dev rpcgen openssl-dev file && \
    mkdir -p /opt/dovecot && cd /opt/dovecot && \
    git init . && \
    git remote add -t ${dovecot_branch} origin https://github.com/dovecot/core && \
    git fetch --depth=1 && git checkout ${dovecot_branch} && \
    ./autogen.sh && \
    mkdir -p ${DOVECOT_PREFIX} && \
    PANDOC=false ./configure ${dovecot_config}

RUN  cd /opt/dovecot && make -s -j$(nproc) && make install 
ARG pigeonhole_branch=master
# release-0.5.10,11 don't compile 20201219
RUN  mkdir /opt/pigeonhole/ && \
    cd /opt/pigeonhole && \
    git init . && git remote add -t ${pigeonhole_branch} origin https://github.com/dovecot/pigeonhole.git && \
    git fetch --depth=1 && git checkout ${pigeonhole_branch} && ./autogen.sh && \
    ./configure ${pigeonhole_config} && \
    make -s -j$(nproc) && make install && \
### Setup Container for Dovecot
    rm -rf /etc/dovecot/* && \
    mkdir -p /var/lib/dovecot && \
    mkdir -p /var/log/dovecot && \
    chown -R ${VMAIL_USER}:${VMAIL_GROUP} /var/lib/dovecot/  ${DOVECOT_PREFIX}  && \
    \
### Cleanup
## this should be removed on prod
    apk add sudo openldap-clients && \
    rm -rf /var/cache/apk/* /usr/src/* 
# rm -rf /opt/dovecot /opt/pigeonhole

### Networking Configuration
EXPOSE 1143 2525 1024 1587 1993 4190

### Add Files
ADD install /
# create DH PEM
RUN ( cd /etc/dovecot && \
    test -f dh.pem || openssl dhparam 4096 > dh.pem ) && \
    chmod g+r /etc/dovecot/dovecot-ldap.conf.ext 
    # for d in $ACCESS_FIX ; do mkdir -p $d ; done && \
    # chown -R ${vmail_uid}.${VMAIL_GROUP}  ${ACCESS_FIX} \
    # &&  find ${ACCESS_FIX} -type d -exec chmod g+wx {} \; \
    # &&  find ${ACCESS_FIX} -type f -exec chmod g+w  {} \; 

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
USER vmail
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["dovecot", "-F"]

# CMD ["/bin/sh"]
