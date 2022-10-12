#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202207101005-git
# @Author            :  Jason Hempstead
# @Contact           :  jason@casjaysdev.com
# @License           :  WTFPL
# @ReadME            :  entrypoint-deno.sh --help
# @Copyright         :  Copyright: (c) 2022 Jason Hempstead, Casjays Developments
# @Created           :  Sunday, Jul 10, 2022 10:05 EDT
# @File              :  entrypoint-deno.sh
# @Description       :
# @TODO              :
# @Other             :
# @Resource          :
# @sudo/root         :  no
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
[ -n "$DEBUG" ] && set -x
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="$(basename "$0" 2>/dev/null)"
VERSION="202207101005-git"
HOME="${USER_HOME:-$HOME}"
USER="${SUDO_USER:-$USER}"
RUN_USER="${SUDO_USER:-$USER}"
SRC_DIR="${BASH_SOURCE%/*}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -'
__exec_bash() { [ $# -ne 0 ] && exec "${*:-bash -l}" || exec /bin/bash -l; }
__find() { ls -A "$*" 2>/dev/null; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
DATA_DIR="$(__find /data/ 2>/dev/null | grep '^' || false)"
CONFIG_DIR="$(__find /config/ 2>/dev/null | grep '^' || false)"
export TZ="${TZ:-America/New_York}"
export HOSTNAME="${HOSTNAME:-casjaysdev-bin}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [[ -n "${TZ}" ]]; then
  echo "${TZ}" >/etc/timezone
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [[ -f "/usr/share/zoneinfo/${TZ}" ]]; then
  ln -sf "/usr/share/zoneinfo/${TZ}" "/etc/localtime"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [[ -n "${HOSTNAME}" ]]; then
  echo "${HOSTNAME}" >/etc/hostname
  echo "127.0.0.1 $HOSTNAME localhost" >/etc/hosts
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[[ -f "/config/.env" ]] && source /config/.env

if [ -z "$1" ] && [ -z "$(ls -A "" 2>/dev/null)" ]; then
  FRESH_INSTALL="true"
  deno run -A -r https://fresh.deno "/data/"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
case "$1" in
--help)
  echo "Usage: $APPNAME [healthcheck, bash, command]"
  exit
  ;;
healthcheck)
  type -P deno &>/dev/null && echo 'OK' || exit 1
  ;;
sh | bash | shell | /bin/sh | /bin/bash)
  shift 1
  __exec_bash "$@"
  ;;

deno)
  shift 1
   deno run --allow-net "${@:-/data/sample.ts}"
  ;;
*)
  if [ "$FRESH_INSTALL" = "true" ]; then
    deno --allow-all task start
  else
    deno run --watch --allow-all "${@:-/data/sample.ts}"
  fi
  ;;
esac
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#end
