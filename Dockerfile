FROM casjaysdevdocker/debian:latest as build

ARG TIMEZONE="America/New_York" \
  IMAGE_NAME="alpine" \
  LICENSE="MIT" \
  DEBUG="" \ 
  DENO_VERSION="v1.26.1" \
  PORTS="1-65535"

ENV TZ="$TIMEZONE" \
  DEBUG="$DEBUG" \
  SHELL="/bin/bash" \
  ENV="$HOME/.bashrc" \
  TERM="xterm-256color" \
  HOSTNAME="${HOSTNAME:-casjaysdev-$IMAGE_NAME}" \
  DENO_VERSION="$DENO_VERSION"

RUN set -ex; \
  rm -Rf "/etc/apk/repositories"; \
  apt-get update && apt-get upgrade -yy && apt-get install -yy \
  unzip

COPY ./bin/. /usr/local/bin/
COPY ./data/. /usr/local/share/template-files/data/
COPY ./config/. /usr/local/share/template-files/config/

RUN chmod -Rf 755 /usr/local/bin/get-deno.sh && \
  /usr/local/bin/get-deno.sh && \
  rm -Rf /usr/local/bin/get-deno.sh /tmp/* /bin/.gitkeep /config /data /var/lib/apt/lists/*

FROM scratch

ARG BUILD_DATE="$(date +'%Y-%m-%d %H:%M')"

LABEL org.label-schema.name="deno" \
  org.label-schema.description="containerized version of deno" \
  org.label-schema.url="https://github.com/casjaysdevdocker/deno/deno" \
  org.label-schema.vcs-url="https://github.com/casjaysdevdocker/deno/deno" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.version=$BUILD_DATE \
  org.label-schema.vcs-ref=$BUILD_DATE \
  org.label-schema.license="WTFPL" \
  org.label-schema.vcs-type="Git" \
  org.label-schema.schema-version="latest" \
  org.label-schema.vendor="CasjaysDev" \
  maintainer="CasjaysDev <docker-admin@casjaysdev.com>"

ENV SHELL="/bin/bash" \
  ENV="$HOME/.bashrc" \
  TERM="xterm-256color" \
  HOSTNAME="casjaysdev-alpine" \
  TZ="${TZ:-America/New_York}" \
  TIMEZONE="$TIMEZONE" \
  PHP_SERVER="none" \
  PORT=""

COPY --from=build /. /

WORKDIR /data/htdocs/www

VOLUME [ "/config","/data" ]

EXPOSE $PORTS

ENTRYPOINT [ "tini", "-p", "SIGTERM", "--" ]
CMD [ "/usr/local/bin/entrypoint-deno.sh" ]
HEALTHCHECK --start-period=1m --interval=2m --timeout=3s CMD [ "/usr/local/bin/entrypoint-deno.sh", "healthcheck" ]
