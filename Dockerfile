FROM casjaysdevdocker/debian:latest as build

ARG TIMEZONE="America/New_York" \
  IMAGE_NAME="deno" \
  LICENSE="MIT" \
  PORTS="1-65535" \
  DEBUG="" \ 
  DENO_VERSION="v1.26.1"

ENV TZ="$TIMEZONE" \
  SHELL="/bin/bash" \
  TERM="xterm-256color" \
  HOSTNAME="${HOSTNAME:-casjaysdev-$IMAGE_NAME}" \
  DENO_VERSION="$DENO_VERSION" \
  DEBUG="$DEBUG"


RUN set -ex; \
  mkdir -p "/usr/local/share/template-files/data/htdocs/www" && \
  apt-get update && apt-get upgrade -yy && apt-get install -yy \
  unzip && \
  git clone -q "https://github.com/casjay-templates/bunjs" "/usr/local/share/template-files/data/htdocs/www"

COPY ./bin/. /usr/local/bin/
COPY ./data/. /usr/local/share/template-files/data/
COPY ./config/. /usr/local/share/template-files/config/

RUN chmod -Rf 755 /usr/local/bin/get-deno.sh && \
  /usr/local/bin/get-deno.sh && \
  rm -Rf /usr/local/bin/get-deno.sh /tmp/* /bin/.gitkeep /config /data /var/lib/apt/lists/* /usr/local/share/template-files/data/htdocs/www/.git

FROM scratch
ARG BUILD_DATE="2022-10-12" \
  BUILD_VERSION="latest"

LABEL maintainer="CasjaysDev <docker-admin@casjaysdev.com>" \
  org.opencontainers.image.vcs-type="Git" \
  org.opencontainers.image.name="deno" \
  org.opencontainers.image.base.name="deno" \
  org.opencontainers.image.license="$LICENSE" \
  org.opencontainers.image.vcs-ref="$BUILD_VERSION" \
  org.opencontainers.image.build-date="$BUILD_DATE" \
  org.opencontainers.image.version="$BUILD_VERSION" \
  org.opencontainers.image.schema-version="$BUILD_VERSION" \
  org.opencontainers.image.url="https://hub.docker.com/r/casjaysdevdocker/deno" \
  org.opencontainers.image.vcs-url="https://github.com/casjaysdevdocker/deno" \
  org.opencontainers.image.url.source="https://github.com/casjaysdevdocker/deno" \
  org.opencontainers.image.documentation="https://hub.docker.com/r/casjaysdevdocker/deno" \
  org.opencontainers.image.vendor="CasjaysDev" \
  org.opencontainers.image.authors="CasjaysDev" \
  org.opencontainers.image.description="Containerized version of deno"

ENV SHELL="/bin/bash" \
  TERM="xterm-256color" \
  HOSTNAME="casjaysdev-deno" \
  TZ="${TZ:-America/New_York}" \
  TIMEZONE="$$TIMEZONE" \
  PHP_SERVER="none" \
  PORT=""

COPY --from=build /. /

WORKDIR /root

VOLUME [ "/config","/data" ]

EXPOSE $PORTS

ENTRYPOINT [ "tini", "-p", "SIGTERM", "--" ]
CMD [ "/usr/local/bin/entrypoint-deno.sh" ]
HEALTHCHECK --start-period=1m --interval=2m --timeout=3s CMD [ "/usr/local/bin/entrypoint-deno.sh", "healthcheck" ]

