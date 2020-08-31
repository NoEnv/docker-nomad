FROM alpine:3.12

LABEL maintainer "NoEnv"
LABEL version "0.12.3"
LABEL description "Nomad Agent as Docker Image"

ENV NOMAD_VERSION=0.12.3
ENV HASHICORP_RELEASES=https://releases.hashicorp.com
ENV GLIBC_VERSION "2.32-r0"

RUN addgroup nomad && \
    adduser -S -G nomad nomad && \
    apk add --no-cache ca-certificates dumb-init gnupg libcap openssl su-exec && \
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys 51852D87348FFC4C && \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    wget https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    apk add --allow-untrusted /tmp/build/glibc-${GLIBC_VERSION}.apk && \
    wget ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip && \
    wget ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS && \
    wget ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify nomad_${NOMAD_VERSION}_SHA256SUMS.sig nomad_${NOMAD_VERSION}_SHA256SUMS && \
    grep nomad_${NOMAD_VERSION}_linux_amd64.zip nomad_${NOMAD_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /bin nomad_${NOMAD_VERSION}_linux_amd64.zip && \
    apk del gnupg openssl && \
    rm -rf /tmp/build /root/.gnupg /var/cache/apk/* /etc/alpine-release && \
    mkdir -p /nomad/data && \
    mkdir -p /nomad/config && \
    chown -R nomad:nomad /nomad

VOLUME /nomad/data

EXPOSE 4646 4647 4648 4648/udp

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["agent", "-dev"]
