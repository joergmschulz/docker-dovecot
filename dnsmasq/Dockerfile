# borrowed from https://github.com/ricardbejarano/dnsmasq/blob/master/Dockerfile


FROM alpine:edge AS build

ARG VERSION="2.86"
ARG CHECKSUM="ef15f608a83ee2b1d1d2c1f11d089a7e0ac401ffb0991de73fc01ce5f290e512"

ARG DNSMASQ_GID
ARG DNSMASQ_GROUP
ARG DNSMASQ_USER
ARG DNSMASQ_UID
ARG DNSMASQ_IP=0.0.0.0


ADD http://www.thekelleys.org.uk/dnsmasq/dnsmasq-$VERSION.tar.gz /tmp/dnsmasq.tar.gz
RUN [ "$(sha256sum /tmp/dnsmasq.tar.gz | awk '{print $1}')" = "$CHECKSUM" ] && \
    apk add gcc linux-headers make musl-dev && \
    tar -C /tmp -xf /tmp/dnsmasq.tar.gz && \
    cd /tmp/dnsmasq-$VERSION && \
      make LDFLAGS="-static"

RUN mkdir -p /rootfs/bin && \
      cp /tmp/dnsmasq-$VERSION/src/dnsmasq /rootfs/bin/ && \
    mkdir -p /rootfs/etc && \
      echo "nogroup:*:${DNSMASQ_UID}:nobody" > /rootfs/etc/group && \
      echo "nobody:*:${DNSMASQ_UID}:${DNSMASQ_GID}:::" > /rootfs/etc/passwd
RUN mkdir -p /rootfs/var/run && \
    chown -R :${DNSMASQ_GID} /rootfs/var/run

FROM scratch

COPY --from=build --chown=${DNSMASQ_UID}:${DNSMASQ_GID} /rootfs /

USER ${DNSMASQ_UID}:${DNSMASQ_GID}
# EXPOSE 1053/udp
ENTRYPOINT ["/bin/dnsmasq"]
CMD ["--keep-in-foreground", "--port=53"]
