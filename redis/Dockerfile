FROM alpine:edge

ARG redis_gid
ARG REDIS_GROUP
ARG REDIS_USER
ARG redis_uid

ARG REDIS_IP=0.0.0.0
ARG REDIS_PASSWORD
# ENV REDIS_PASSWORD=TakeItFromDotEnv
ENV REDIS_VERSION 6.0.9
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-6.0.9.tar.gz
ENV REDIS_DOWNLOAD_SHA dc2bdcf81c620e9f09cfd12e85d3bc631c897b2db7a55218fd8a65eaa37f86dd


RUN set -eux && \
    addgroup -S -g ${redis_gid} $REDIS_GROUP || export REDIS_GROUP=root  && \
    adduser -S -D -H -u $redis_uid -G $REDIS_GROUP -g "Redis user" ${REDIS_USER} && \

    apk add --no-cache \
    # grab su-exec for easy step-down from root
    		# 'su-exec>=0.2' \
    # add tzdata for https://github.com/docker-library/redis/issues/138
    		tzdata



    RUN set -eux; \
    	\
    	apk add --no-cache --virtual .build-deps \
    		coreutils \
    		dpkg-dev dpkg \
    		gcc \
    		linux-headers \
    		make \
    		musl-dev \
    		openssl-dev \
    # install real "wget" to avoid:
    #   + wget -O redis.tar.gz http://download.redis.io/releases/redis-6.0.6.tar.gz
    #   Connecting to download.redis.io (45.60.121.1:80)
    #   wget: bad header line:     XxhODalH: btu; path=/; Max-Age=900
    		wget \
    	; \
    	\
    	wget -O redis.tar.gz "$REDIS_DOWNLOAD_URL"; \
    	echo "$REDIS_DOWNLOAD_SHA *redis.tar.gz" | sha256sum -c -; \
    	mkdir -p /usr/src/redis; \
    	tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1; \
    	rm redis.tar.gz; \
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
    	rm -r /usr/src/redis; \
    	\
    	runDeps="$( \
    		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
    			| tr ',' '\n' \
    			| sort -u \
    			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    	)"; \
    	apk add --no-network --virtual .redis-rundeps $runDeps; \
    	apk del --no-network .build-deps; \
    	\
    	redis-cli --version; \
    	redis-server --version

    RUN mkdir /data && \
        chown $REDIS_USER:$REDIS_GROUP /data && \
    rm -rf /var/cache/apk/* && \
    \
# Workspace and Volume Setup
    mkdir -p /data && \
    chown -R redis /data





RUN mkdir -p /usr/local/etc/redis && \
printf "bind ${REDIS_IP}\n\
save 900 1\n\
save 300 10\n\
save 60 10000\n\
protected-mode yes\n\
dir /data\n\
requirepass ${REDIS_PASSWORD}\n\
port 6379\n"\
> /usr/local/etc/redis/redis.conf

USER redis
CMD ["/usr/local/bin/redis-server",  "/usr/local/etc/redis/redis.conf"]
