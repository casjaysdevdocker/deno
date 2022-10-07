FROM casjaysdevdocker/debian:latest as build

ENV VERSION="v1.23.3" \
  DEBIAN_FRONTEND=noninteractive

RUN apt update && \
  apt upgrade -yy && \
  apt install unzip -yy && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

COPY ./bin/. /usr/local/bin/
COPY ./config/. /config/
COPY ./data/. /data/

RUN chmod -Rf 755 /usr/local/bin/get-deno.sh && \
  /usr/local/bin/get-deno.sh && \
  rm -Rf /usr/local/bin/get-deno.sh

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
  TERM="xterm-256color" \
  HOSTNAME="casjaysdev-deno" \
  TZ="${TZ:-America/New_York}"

WORKDIR /app
VOLUME ["/app"]
EXPOSE 1993

COPY --from=build /. /

HEALTHCHECK --interval=15s --timeout=3s CMD [ "/usr/local/bin/entrypoint-deno.sh", "healthcheck" ]

ENTRYPOINT [ "/usr/local/bin/entrypoint-deno.sh" ]
