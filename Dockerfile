FROM casjaysdevdocker/debian:latest AS build

ARG DEBIAN_VERSION="bullseye"

ARG DEFAULT_DATA_DIR="/usr/local/share/template-files/data" \
  DEFAULT_CONF_DIR="/usr/local/share/template-files/config" \
  DEFAULT_TEMPLATE_DIR="/usr/local/share/template-files/defaults"

ARG PACK_LIST="unzip"

ARG DEBUG="" \
  DENO_VERSION="v1.26.1"

ENV LANG=en_US.UTF-8 \
  ENV=ENV=~/.bashrc \
  TZ="America/New_York" \
  SHELL="/bin/sh" \
  TERM="xterm-256color" \
  TIMEZONE="${TZ:-$TIMEZONE}" \
  HOSTNAME="casjaysdev-deno" \
  DEBIAN_FRONTEND="noninteractive" \
  DENO_VERSION="$DENO_VERSION" \
  DEBUG="$DEBUG"

COPY ./rootfs/. /

RUN set -ex; \
  rm -Rf "/etc/apt/sources.list" ; \
  mkdir -p "${DEFAULT_DATA_DIR}" "${DEFAULT_CONF_DIR}" "${DEFAULT_TEMPLATE_DIR}" ; \
  echo 'export DEBIAN_FRONTEND="noninteractive"' >"/etc/profile.d/apt.sh" && chmod 755 "/etc/profile.d/apt.sh" && \
  echo "deb http://deb.debian.org/debian ${DEBIAN_VERSION} main contrib non-free" >>"/etc/apt/sources.list" ; \
  echo "deb http://deb.debian.org/debian ${DEBIAN_VERSION}-updates main contrib non-free" >>"/etc/apt/sources.list" ; \
  echo "deb http://deb.debian.org/debian-security/ ${DEBIAN_VERSION}-security main contrib non-free" >>"/etc/apt/sources.list" ; \
  apt-get update -yy && apt-get upgrade -yy && apt-get install -yy ${PACK_LIST} && \
  sed -i -e "s/# en_US.UTF-8.*/en_US.UTF-8 UTF-8/" /etc/locale.gen && \
  dpkg-reconfigure --frontend=noninteractive locales && \
  update-locale LANG=en_US.UTF-8 && \
  git clone -q "https://github.com/casjay-templates/denojs" "${DEFAULT_DATA_DIR}/htdocs/www" && \
  cd "${DEFAULT_DATA_DIR}/htdocs/www" && /usr/local/bin/get-deno.sh

RUN echo 'Running cleanup' ; \
  apt-get clean ; \
  update-alternatives --install /bin/sh sh /bin/bash 1 ; \
  rm -Rf /usr/share/doc/* /usr/share/info/* /tmp/* /var/tmp/* usr/local/bin/get-deno.sh; \
  rm -Rf /usr/local/bin/.gitkeep /config /data /var/lib/apt/lists/* ; \
  rm -rf /lib/systemd/system/multi-user.target.wants/* ; \
  rm -rf /etc/systemd/system/*.wants/* ; \
  rm -rf /lib/systemd/system/local-fs.target.wants/* ; \
  rm -rf /lib/systemd/system/sockets.target.wants/*udev* ; \
  rm -rf /lib/systemd/system/sockets.target.wants/*initctl* ; \
  rm -rf /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* ; \
  rm -rf /lib/systemd/system/systemd-update-utmp* ; \
  if [ -d "/lib/systemd/system/sysinit.target.wants" ]; then cd "/lib/systemd/system/sysinit.target.wants" && rm $(ls | grep -v systemd-tmpfiles-setup) ; fi

FROM scratch

ARG \
  SERVICE_PORT="" \
  EXPOSE_PORTS="1-65535" \
  PHP_SERVER="deno" \
  NODE_VERSION="system" \
  NODE_MANAGER="system" \
  BUILD_VERSION="latest" \
  LICENSE="MIT" \
  IMAGE_NAME="deno" \
  BUILD_DATE="Fri Oct 21 12:36:59 AM EDT 2022" \
  TIMEZONE="America/New_York"

LABEL maintainer="CasjaysDev <docker-admin@casjaysdev.com>" \
  org.opencontainers.image.vendor="CasjaysDev" \
  org.opencontainers.image.authors="CasjaysDev" \
  org.opencontainers.image.vcs-type="Git" \
  org.opencontainers.image.name="${IMAGE_NAME}" \
  org.opencontainers.image.base.name="${IMAGE_NAME}" \
  org.opencontainers.image.license="${LICENSE}" \
  org.opencontainers.image.vcs-ref="${BUILD_VERSION}" \
  org.opencontainers.image.build-date="${BUILD_DATE}" \
  org.opencontainers.image.version="${BUILD_VERSION}" \
  org.opencontainers.image.schema-version="${BUILD_VERSION}" \
  org.opencontainers.image.url="https://hub.docker.com/r/casjaysdevdocker/${IMAGE_NAME}" \
  org.opencontainers.image.vcs-url="https://github.com/casjaysdevdocker/${IMAGE_NAME}" \
  org.opencontainers.image.url.source="https://github.com/casjaysdevdocker/${IMAGE_NAME}" \
  org.opencontainers.image.documentation="https://hub.docker.com/r/casjaysdevdocker/${IMAGE_NAME}" \
  org.opencontainers.image.description="Containerized version of ${IMAGE_NAME}"

ENV LANG=en_US.UTF-8 \
  ENV=~/.bashrc \
  SHELL="/bin/bash" \
  PORT="${SERVICE_PORT}" \
  TERM="xterm-256color" \
  PHP_SERVER="${PHP_SERVER}" \
  NODE_VERSION="${NODE_VERSION}" \
  NODE_MANAGER="${NODE_MANAGER}" \
  CONTAINER_NAME="${IMAGE_NAME}" \
  TZ="${TZ:-America/New_York}" \
  TIMEZONE="${TZ:-$TIMEZONE}" \
  HOSTNAME="casjaysdev-${IMAGE_NAME}" \
  USER="root"

COPY --from=build /. /

USER root
WORKDIR /data/htdocs/www

VOLUME [ "/config","/data" ]

EXPOSE $EXPOSE_PORTS

#CMD [ "" ]
ENTRYPOINT [ "tini", "-p", "SIGTERM", "--", "/usr/local/bin/entrypoint.sh" ]
HEALTHCHECK --start-period=1m --interval=2m --timeout=3s CMD [ "/usr/local/bin/entrypoint.sh", "healthcheck" ]
