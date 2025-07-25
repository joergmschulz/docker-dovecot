FROM alpine:3.21

ARG redis_gid
ARG REDIS_GROUP
ARG REDIS_USER
ARG redis_uid
ARG REDIS_IP=0.0.0.0
ARG REDIS_PASSWORD
# ENV REDIS_PASSWORD=TakeItFromDotEnv
ENV REDIS_VERSION 7.2.4
# ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-6.2.3.tar.gz
# ENV REDIS_DOWNLOAD_SHA 98ed7d532b5e9671f5df0825bb71f0f37483a16546364049384c63db8764512b
# hashes come from https://github.com/redis/redis-hashes
# ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-6.2.6.tar.gz
# ENV REDIS_DOWNLOAD_SHA 5b2b8b7a50111ef395bf1c1d5be11e6e167ac018125055daa8b5c2317ae131ab
ENV REDIS_DOWNLOAD_URL http://download.redis.io/redis-stable.tar.gz
ENV REDIS_DOWNLOAD_SHA_URL http://download.redis.io/redis-stable.tar.gz.SHA256SUM

RUN set -eux; \
    addgroup -S -g ${redis_gid} $REDIS_GROUP || export REDIS_GROUP=root  && \
    adduser -S -D -H -u $redis_uid -G $REDIS_GROUP -g "Redis user" ${REDIS_USER} && \
    \
    apk add --no-cache --virtual .build-deps \
        coreutils \
        dpkg-dev dpkg \
        gcc \
        linux-headers \
        make \
        musl-dev \
        openssl-dev \
        g++; \
    \
    arch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    case "$arch" in \
        'amd64') export BUILD_WITH_MODULES=yes; export INSTALL_RUST_TOOLCHAIN=yes; export DISABLE_WERRORS=yes ;; \
        'arm64') export BUILD_WITH_MODULES=yes; export INSTALL_RUST_TOOLCHAIN=yes; export DISABLE_WERRORS=yes ;; \
        *) echo >&2 "Modules are NOT supported! unsupported architecture: '$arch'"; export BUILD_WITH_MODULES=no ;; \
    esac; \
    if [ "$BUILD_WITH_MODULES" = "yes" ]; then \
    apk add --no-cache --virtual .module-build-deps \
        autoconf \
        automake \
        bash \
        bsd-compat-headers \
        build-base \
        cargo \
        clang \
        clang18-libclang \
        cmake \
        curl \
        g++ \
        git \
        libffi-dev \
        libgcc \
        libtool \
        openssh \
        openssl  \
        py-virtualenv \
        py3-cryptography \
        py3-pip \
        py3-virtualenv \
        python3 \
        python3-dev \
        rsync \
        tar \
        unzip \
        which \
        xsimd \
        xz; \
    fi; \
    \
# install required python packages for RedisJSON module
    pip install -q --upgrade setuptools &&  pip install -q --upgrade pip && PIP_BREAK_SYSTEM_PACKAGES=1 pip install -q addict toml jinja2 ramp-packer ;\
    wget -O redis-stable.tar.gz "$REDIS_DOWNLOAD_URL"; \
    wget -O REDIS_DOWNLOAD_SHA "$REDIS_DOWNLOAD_SHA_URL"; \
    echo  $(cat REDIS_DOWNLOAD_SHA)  | sha256sum -c -; \
    mkdir -p /usr/src/redis; \
    tar -xzf redis-stable.tar.gz -C /usr/src/redis --strip-components=1; \
    rm redis-stable.tar.gz REDIS_DOWNLOAD_SHA ; \
    \
# disable Redis protected mode [1] as it is unnecessary in context of Docker
# (ports are not automatically exposed when running inside Docker, but rather explicitly by specifying -p / -P)
# [1]: https://github.com/redis/redis/commit/edd4d555df57dc84265fdfb4ef59a4678832f6da
    grep -E '^ *createBoolConfig[(]"protected-mode",.*, *1 *,.*[)],$' /usr/src/redis/src/config.c; \
    sed -ri 's!^( *createBoolConfig[(]"protected-mode",.*, *)1( *,.*[)],)$!\10\2!' /usr/src/redis/src/config.c; \
    grep -E '^ *createBoolConfig[(]"protected-mode",.*, *0 *,.*[)],$' /usr/src/redis/src/config.c; \
# for future reference, we modify this directly in the source instead of just supplying a default configuration flag because apparently "if you specify any argument to redis-server, [it assumes] you are going to specify everything"
# see also https://github.com/docker-library/redis/issues/4#issuecomment-50780840
# (more exactly, this makes sure the default behavior of "save on SIGTERM" stays functional by default)
    \
# https://github.com/jemalloc/jemalloc/issues/467 -- we need to patch the "./configure" for the bundled jemalloc to match how Debian compiles, for compatibility
# (also, we do cross-builds, so we need to embed the appropriate "--build=xxx" values to that "./configure" invocation)
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    extraJemallocConfigureFlags="--build=$gnuArch"; \
# https://salsa.debian.org/debian/jemalloc/-/blob/c0a88c37a551be7d12e4863435365c9a6a51525f/debian/rules#L8-23
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64 | i386 | x32) extraJemallocConfigureFlags="$extraJemallocConfigureFlags --with-lg-page=12" ;; \
        *) extraJemallocConfigureFlags="$extraJemallocConfigureFlags --with-lg-page=16" ;; \
    esac; \
    extraJemallocConfigureFlags="$extraJemallocConfigureFlags --with-lg-hugepage=21"; \
    grep -F 'cd jemalloc && ./configure ' /usr/src/redis/deps/Makefile; \
    sed -ri 's!cd jemalloc && ./configure !&'"$extraJemallocConfigureFlags"' !' /usr/src/redis/deps/Makefile; \
    grep -F "cd jemalloc && ./configure $extraJemallocConfigureFlags " /usr/src/redis/deps/Makefile; \
    \
    export BUILD_TLS=yes; \
    if [ "$BUILD_WITH_MODULES" = "yes" ]; then \
        make -C /usr/src/redis/modules/redisjson get_source; \
        sed -i 's/^RUST_FLAGS=$/RUST_FLAGS += -C target-feature=-crt-static/' /usr/src/redis/modules/redisjson/src/Makefile ; \
        grep -E 'RUST_FLAGS' /usr/src/redis/modules/redisjson/src/Makefile; \
    fi; \
    make -C /usr/src/redis -j "$(nproc)" all; \
    make -C /usr/src/redis install; \
    \
# TODO https://github.com/redis/redis/pull/3494 (deduplicate "redis-server" copies)
    serverMd5="$(md5sum /usr/local/bin/redis-server | cut -d' ' -f1)"; export serverMd5; \
    find /usr/local/bin/redis* -maxdepth 0 \
        -type f -not -name redis-server \
        -exec sh -eux -c ' \
            md5="$(md5sum "$1" | cut -d" " -f1)"; \
            test "$md5" = "$serverMd5"; \
        ' -- '{}' ';' \
        -exec ln -svfT 'redis-server' '{}' ';' \
    ; \
    \
    make -C /usr/src/redis distclean; \
    rm -r /usr/src/redis; \
    \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-network --virtual .redis-rundeps $runDeps; \
    if [ "$BUILD_WITH_MODULES" = "yes" ]; then \
        apk del --no-network .module-build-deps; \
    fi; \
    apk del --no-network .build-deps; \
    rm -rf ~/.cache ~/.gitconfig; \
    \
    redis-cli --version; \
    redis-server --version;

    RUN mkdir /data && \
        chown $REDIS_USER:$REDIS_GROUP /data && \
    rm -rf /var/cache/apk/* && \
    \
# Workspace and Volume Setup
    mkdir -p /data && \
    chown -R ${REDIS_USER}:${REDIS_GROUP} /data


ARG ACCESS_FIX="/usr/local/etc/redis"
RUN for d in ${ACCESS_FIX} ; do mkdir -p $d ; done && \
        chown -R ${REDIS_USER}:${REDIS_GROUP} ${ACCESS_FIX} && \
        find ${ACCESS_FIX} -type d -exec chmod g+wx {} \;


RUN mkdir -p /usr/local/etc/redis
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER $REDIS_USER
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# CMD /bin/sh
