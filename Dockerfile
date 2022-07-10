FROM casjaysdevdocker/alpine:latest as source

RUN apk --no-cache add --update cargo rust && \
      git clone --recurse-submodules https://github.com/denoland/deno.git /build && \
      cd /build && cargo cargo clean && cargo build -vv && ./target/release/deno --version || exit 10

COPY ./bin/. /usr/local/bin/
COPY ./config/. /config/
COPY ./data/. /data/

FROM casjaysdevdocker/alpine:latest as build

COPY --from=source /build/target/release/deno /usr/bin/deno

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

WORKDIR /root
VOLUME ["/root","/config"]
EXPOSE 9090

COPY --from=build /. /

HEALTHCHECK CMD [ "/usr/local/bin/entrypoint-deno.sh", "healthcheck" ]
ENTRYPOINT [ "/usr/local/bin/entrypoint-deno.sh" ]
CMD [ "/usr/bin/bash", "-l" ]

