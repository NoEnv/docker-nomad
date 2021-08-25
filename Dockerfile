ARG NOMAD_VERSION=1.1.3
ARG PODMAN_DRIVER_VERSION=0.3.0
ARG HASHICORP_RELEASES=https://releases.hashicorp.com
ARG ARCHITECTURE=amd64

FROM alpine:3.14

LABEL maintainer "NoEnv"
LABEL version "1.1.3"
LABEL description "Nomad Agent as Docker Image"

RUN addgroup nomad && \
    adduser -S -G nomad nomad && \
    apk add --no-cache ca-certificates dumb-init gnupg libcap openssl su-exec gcompat && \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 51852D87348FFC4C 34365D9472D7468F && \
    mkdir -p /tmp/build /nomad/data/plugins /nomad/config && \
    cd /tmp/build && \
    wget ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_${ARCHITECTURE}.zip && \
    wget ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS && \
    wget ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify nomad_${NOMAD_VERSION}_SHA256SUMS.sig nomad_${NOMAD_VERSION}_SHA256SUMS && \
    grep nomad_${NOMAD_VERSION}_linux_${ARCHITECTURE}.zip nomad_${NOMAD_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /bin nomad_${NOMAD_VERSION}_linux_${ARCHITECTURE}.zip && \
    wget ${HASHICORP_RELEASES}/nomad-driver-podman/${PODMAN_DRIVER_VERSION}/nomad-driver-podman_${PODMAN_DRIVER_VERSION}_linux_${ARCHITECTURE}.zip && \
    wget ${HASHICORP_RELEASES}/nomad-driver-podman/${PODMAN_DRIVER_VERSION}/nomad-driver-podman_${PODMAN_DRIVER_VERSION}_SHA256SUMS && \
    wget ${HASHICORP_RELEASES}/nomad-driver-podman/${PODMAN_DRIVER_VERSION}/nomad-driver-podman_${PODMAN_DRIVER_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify nomad-driver-podman_${PODMAN_DRIVER_VERSION}_SHA256SUMS.sig nomad-driver-podman_${PODMAN_DRIVER_VERSION}_SHA256SUMS && \
    grep nomad-driver-podman_${PODMAN_DRIVER_VERSION}_linux_${ARCHITECTURE}.zip nomad-driver-podman_${PODMAN_DRIVER_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /nomad/data/plugins nomad-driver-podman_${PODMAN_DRIVER_VERSION}_linux_${ARCHITECTURE}.zip && \
    apk del gnupg openssl && \
    rm -rf /tmp/build /root/.gnupg /var/cache/apk/* /etc/alpine-release && \
    chown -R nomad:nomad /nomad

EXPOSE 4646 4647 4648 4648/udp

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["agent", "-dev"]
