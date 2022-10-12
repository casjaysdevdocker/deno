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
DENO_VERSION="${DENO_VERSION:-v1.26.1}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ "$(uname -m)" = "amd64" ] || [ "$(uname -m)" = "x86_64" ]; then
  ARCH="x86_64"
  URL="https://github.com/denoland/deno/releases/download/$DENO_VERSION/deno-$ARCH-unknown-linux-gnu.zip"
  BIN_FILE="/usr/bin/deno"
  TMP_DIR="/tmp/deno-$ARCH"
  FILE="/tmp/deno-$ARCH.zip"
  message="grabbing $DENO_VERSION from denoland for $ARCH"
  err_mess="Failed to download deno from $URL"
elif [ "$(uname -m)" = "arm64" ] || [ "$(uname -m)" = "aarch64" ]; then
  ARCH="arm64"
  URL="https://github.com/LukeChannings/deno-arm64/releases/download/$DENO_VERSION/deno-linux-$ARCH.zip"
  BIN_FILE="/usr/bin/deno"
  TMP_DIR="/tmp/deno-$ARCH"
  FILE="/tmp/deno-$ARCH.zip"
  message="grabbing $DENO_VERSION from LukeChannings for $ARCH"
  err_mess="Failed to download deno from $URL"
else
  echo "Unsupported architecture"
  exit 1
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo "$message"
if curl -q -LSsf -o "$FILE" "$URL"; then
  mkdir -p "$TMP_DIR" && cd "$TMP_DIR" || exit 10
  unzip "$FILE"
  mv -fv "$TMP_DIR/deno" "$BIN_FILE"
  chmod -Rf 755 "$BIN_FILE"
else
  echo "$err_mess"
  exit 2
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#rm -Rf "$FILE" "$TMP_DIR"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -f "$(which "deno")" ] && deno upgrade && exit 0 || exit 10
