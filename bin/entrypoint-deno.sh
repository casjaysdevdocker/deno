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
APPNAME="$(basename "$0" 2>/dev/null)"
VERSION="202207101005-git"
HOME="${USER_HOME:-$HOME}"
USER="${SUDO_USER:-$USER}"
RUN_USER="${SUDO_USER:-$USER}"
SRC_DIR="${BASH_SOURCE%/*}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
if [[ "$1" == "--debug" ]]; then shift 1 && set -xo pipefail && export SCRIPT_OPTS="--debug" && export _DEBUG="on"; fi
trap 'exitCode=${exitCode:-$?}' EXIT

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
[[ -f "/app/.env" ]] && source /app/.env
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
case "$1" in
--help)
  echo "Usage: $APPNAME [healthcheck, bash, command]"
  exit
  ;;
healthcheck)
  echo 'OK'
  ;;
sh | bash | shell | /bin/sh | /bin/bash)
  shift 1
  __exec_bash "$@"
  ;;
*)
  deno run --allow-net "${@:-/data/sample.ts}"
  ;;
esac
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#end
