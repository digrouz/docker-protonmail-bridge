FROM alpine:3.15.3
LABEL maintainer "DI GREGORIO Nicolas <nicolas.digregorio@gmail.com>"

ARG BRIDGE_VERSION='2.1.2'

### Environment variables
ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    TERM='xterm' \
    APPUSER='bridge' \
    APPUID='10039' \
    APPGID='10039' \
    BRIDGE_VERSION="${BRIDGE_VERSION}"
    
### Copy config files
COPY root/ /

### Install Application
RUN set -x && \
    chmod 1777 /tmp && \
    . /usr/local/bin/docker-entrypoint-functions.sh && \
    MYUSER="${APPUSER}" && \
    MYUID="${APPUID}" && \
    MYGID="${APPGID}" && \
    ConfigureUser && \
    apk upgrade --no-cache && \
    apk add --no-cache --virtual=build-deps \
      curl \
      git \
      go \
      libsecret-dev \
      make \
      pkgconfig \
    && \
    cd /tmp && \
    git clone --depth 1 --branch v${BRIDGE_VERSION} https://github.com/ProtonMail/proton-bridge.git /tmp/proton-bridge && \
    cd /tmp/proton-bridge && \
    make build-nogui && \
    apk add --no-cache --virtual=run-deps \
      bash \
      ca-certificates \
      socat \
      su-exec \
    && \
    apk del --no-cache --purge \
      build-deps  \
    && \
    mkdir /docker-entrypoint.d && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    ln -snf /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh && \
    rm -rf /tmp/* \
           /var/cache/apk/*  \
           /var/tmp/*
    
### Volume
Volume ["/config"]

### Expose ports
Expose 25/tcp
Expose 143/tcp

### Running User: not used, managed by docker-entrypoint.sh
#USER bridge

### Start bridge
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bridge"]
