FROM casjaysdevdocker/alpine:latest as source

SHELL [ "/bin/bash" ]
ARG VERSION="v1.23.3"

RUN apk --no-cache add --update \
  cargo \
  rust && \
  mkdir -p /tmp/deno 

RUN { [ "$(uname -m)" = "amd64" ] || [ "$(uname -m)" = "x86_64" ]; } && \
  curl -Lsf "https://github.com/denoland/deno/releases/download/${VERSION}/deno-x86_64-unknown-linux-gnu.zip" -o /tmp/deno.zip || true

RUN { [ "$(uname -m)" = "arm64" ] || [ "$(uname -m)" = "aarch64" ]; } && \
  curl -Lsf https://github.com/LukeChannings/deno-arm64/releases/download/${VERSION}/deno-$(echo $TARGETPLATFORM | tr '/' '-').zip -o /tmp/deno.zip || true

RUN [ -f "/tmp/deno.zip" ] && \
  cd /tmp/deno && \
  unzip /tmp/deno.zip && \
  mv -fv /tmp/deno/deno /usr/bin/deno && \
  chmod +x /usr/bin/deno && \
  rm /tmp/deno.zip /tmp/deno

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

WORKDIR /app
VOLUME ["/app","/config","/data"]
EXPOSE 1993

COPY --from=build /. /

HEALTHCHECK CMD [ "/usr/local/bin/entrypoint-deno.sh", "healthcheck" ]
ENTRYPOINT [ "/usr/local/bin/entrypoint-deno.sh" ]
CMD [ "/usr/bin/bash", "-l" ]
