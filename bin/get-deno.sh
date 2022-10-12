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
DENO_URL_x64="https://github.com/denoland/deno/releases/download/latest/deno-x86_64-unknown-linux-gnu.zip"
DENO_URL_ARM64="https://github.com/LukeChannings/deno-arm64/releases/latest/download/deno-linux-arm64.zip"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__get_file() {
  local version_url="${URL//latest/$DENO_VERSION/}"
  if curl -q -LSSf -o "$FILE" "$URL"; then
    DOWNLOAD_URL="$URL"
    return 0
  elif curl -q -LSsf -o "$FILE" "$version_url"; then
    DOWNLOAD_URL="$version_url"
    return 0
  else
    return 1
  fi
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# AMD64 binary
if [ "$(uname -m)" = "amd64" ] || [ "$(uname -m)" = "x86_64" ]; then
  ARCH=x86_64
  URL="$DENO_URL_x64"
  FILE="/tmp/deno-$ARCH.zip"
  echo "grabbing ${DENO_VERSION}/deno-x86_64-unknown-linux-gnu.zip from denoland for $ARCH"
  __get_file && if [ -f "/tmp/deno-$ARCH.zip" ]; then
      mkdir -p "/tmp/deno-$ARCH" && cd "/tmp/deno-$ARCH" || exit 10
      unzip "/tmp/deno-$ARCH.zip"
      mv -fv "/tmp/deno-$ARCH/deno" "/usr/bin/deno"
      chmod -Rf 755 "/usr/bin/deno"
      rm -Rf "/tmp/deno-$ARCH.zip" "/tmp/deno-$ARCH"
    fi
  else
    echo "Failed to download deno from $DOWNLOAD_URL"
    exit 2
  fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ARM64 binary
if [ "$(uname -m)" = "arm64" ] || [ "$(uname -m)" = "aarch64" ]; then
  ARCH=arm64
  URL="$DENO_URL_ARM64"
  FILE="/tmp/deno-$ARCH.zip"
  echo "grabbing ${DENO_VERSION}/deno-linux-arm64.zip from LukeChannings for $ARCH"
    __get_file && if [ -f "/tmp/deno-$ARCH.zip" ]; then
      mkdir -p "/tmp/deno-$ARCH" && cd "/tmp/deno-$ARCH" || exit 10
      unzip "/tmp/deno-$ARCH.zip"
      mv -fv "/tmp/deno-$ARCH/deno" "/usr/bin/deno"
      chmod -Rf 755 "/usr/bin/deno"
      rm -Rf "/tmp/deno-$ARCH.zip" "/tmp/deno-$ARCH"
    fi
  else
    echo "Failed to download deno from $DOWNLOAD_URL"
    exit 2
fi
[ -f "$(which "deno")" ] && deno upgrade && exit 0 || exit 10

