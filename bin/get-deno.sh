#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202207101834-git
# @Author            :  Jason Hempstead
# @Contact           :  jason@casjaysdev.com
# @License           :  LICENSE.md
# @ReadME            :  get-deno.sh --help
# @Copyright         :  Copyright: (c) 2022 Jason Hempstead, Casjays Developments
# @Created           :  Sunday, Jul 10, 2022 18:34 EDT
# @File              :  get-deno.sh
# @Description       :  Download binaries for amd64 and arm64
# @TODO              :
# @Other             :
# @Resource          :
# @sudo/root         :  no
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
[ -n "$DEBUG" ] && set -x
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__get_file() {
  local exitStatus=""
  if curl -q -LSf "$URL" -o "$FILE"; then
    exitStatus=0
  elif curl -q -LSf "$LATEST_URL" -o "$FILE"; then
    URL="$LATEST_URL"
    exitStatus=0
  else
    exitStatus=1
  fi
  return ${exitStatus}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
DENO_VERSION="${DENO_VERSION:-v1.26.1}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ "$(uname -m)" = "amd64" ] || [ "$(uname -m)" = "x86_64" ]; then
  ARCH="x86_64"
  BIN_FILE="/usr/bin/deno"
  FILE="/tmp/deno-$ARCH.zip"
  TMP_DIR="/tmp/deno-$ARCH/deno"
  DENO_VERSION="${DENO_VERSION:-latest}"
  URL="https://github.com/denoland/deno/releases/download/$DENO_VERSION/deno-$ARCH-unknown-linux-gnu.zip"
  LATEST_URL="https://github.com/denoland/deno/releases/download/latest/deno-$ARCH-unknown-linux-gnu.zip"
elif [ "$(uname -m)" = "arm64" ] || [ "$(uname -m)" = "aarch64" ]; then
  ARCH="arm64"
  BIN_FILE="/usr/bin/deno"
  FILE="/tmp/deno-$ARCH.zip"
  DENO_VERSION="${DENO_VERSION:-latest}"
  URL="https://github.com/LukeChannings/deno-arm64/releases/download/$DENO_VERSION/deno-linux-$ARCH.zip"
  LATEST_URL="https://github.com/LukeChannings/deno-arm64/releases/latest/download/deno-linux-$ARCH.zip"
else
  echo "Unsupported architecture"
  exit 1
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# AMD64 binary
if [ "$ARCH" = "x86_64" ]; then
  echo "grabbing ${DENO_VERSION} from denoland for $ARCH"
  __get_file && if [ -f "$FILE" ]; then
    mkdir -p "$TMP_DIR" && cd "$TMP_DIR" || exit 10
    unzip "$FILE"
    mv -fv "$TMP_DIR" "$BIN_FILE"
    chmod -Rf 755 "$BIN_FILE"
    rm -Rf "$FILE" "$TMP_DIR"
  fi
else
  echo "Failed to download deno from $URL"
  exit 2
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ARM64 binary
if [ "$ARCH" = "arm64" ]; then
  echo "grabbing ${DENO_VERSION} from LukeChannings for $ARCH"
  __get_file && if [ -f "$FILE" ]; then
    mkdir -p "$TMP_DIR" && cd "$TMP_DIR" || exit 10
    unzip "$FILE"
    mv -fv "$TMP_DIR" "$BIN_FILE"
    chmod -Rf 755 "$BIN_FILE"
    rm -Rf "$FILE" "$TMP_DIR"
  fi
else
  echo "Failed to download deno from $URL"
  exit 2
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -f "$(which "deno")" ] && deno upgrade && exit 0 || exit 10
