FROM registry.fedoraproject.org/fedora-minimal:37

ENV NOMAD_VERSION=1.5.2 \
    PODMAN_DRIVER_VERSION=0.4.1 \
    HASHICORP_RELEASES=https://releases.hashicorp.com

LABEL maintainer "NoEnv"
LABEL version "1.5.2"
LABEL description "Nomad Agent as Docker Image"

RUN microdnf -y --nodocs install iproute systemd-libs unzip shadow-utils && \
    case "$(arch)" in \
       aarch64|arm64|arm64e) \
         ARCHITECTURE='arm64'; \
         ;; \
       x86_64|amd64|i386) \
         ARCHITECTURE='amd64'; \
         ;; \
       *) \
         echo "Unsupported architecture"; \
         exit 1; \
         ;; \
    esac; \
    useradd -u 100 -r -d /nomad nomad && \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 51852D87348FFC4C 34365D9472D7468F && \
    mkdir -p /tmp/build /nomad/data/plugins /nomad/config && \
    cd /tmp/build && \
    curl -s -O ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_${ARCHITECTURE}.zip && \
    curl -s -O ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS && \
    curl -s -O ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify nomad_${NOMAD_VERSION}_SHA256SUMS.sig nomad_${NOMAD_VERSION}_SHA256SUMS && \
    grep nomad_${NOMAD_VERSION}_linux_${ARCHITECTURE}.zip nomad_${NOMAD_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /bin nomad_${NOMAD_VERSION}_linux_${ARCHITECTURE}.zip && \
    curl -s -O ${HASHICORP_RELEASES}/nomad-driver-podman/${PODMAN_DRIVER_VERSION}/nomad-driver-podman_${PODMAN_DRIVER_VERSION}_linux_${ARCHITECTURE}.zip && \
    curl -s -O ${HASHICORP_RELEASES}/nomad-driver-podman/${PODMAN_DRIVER_VERSION}/nomad-driver-podman_${PODMAN_DRIVER_VERSION}_SHA256SUMS && \
    curl -s -O ${HASHICORP_RELEASES}/nomad-driver-podman/${PODMAN_DRIVER_VERSION}/nomad-driver-podman_${PODMAN_DRIVER_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify nomad-driver-podman_${PODMAN_DRIVER_VERSION}_SHA256SUMS.sig nomad-driver-podman_${PODMAN_DRIVER_VERSION}_SHA256SUMS && \
    grep nomad-driver-podman_${PODMAN_DRIVER_VERSION}_linux_${ARCHITECTURE}.zip nomad-driver-podman_${PODMAN_DRIVER_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /nomad/data/plugins nomad-driver-podman_${PODMAN_DRIVER_VERSION}_linux_${ARCHITECTURE}.zip && \
    microdnf -y remove unzip shadow-utils libsemanage && microdnf clean all && \
    rm -f /etc/fedora-release /etc/redhat-release /etc/system-release /etc/system-release-cpe && \
    rm -rf /tmp/* /var/tmp/* /var/log/*.log /var/cache/yum/* /var/lib/dnf/* /var/lib/rpm/* /root/.gnupg && \
    chown -R nomad:nomad /nomad

EXPOSE 4646 4647 4648 4648/udp

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["agent", "-dev"]
