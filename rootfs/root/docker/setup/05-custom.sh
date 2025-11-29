#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202511291200-git
# @@Author           :  CasjaysDev
# @@Contact          :  CasjaysDev <docker-admin@casjaysdev.pro>
# @@License          :  MIT
# @@ReadME           :
# @@Copyright        :  Copyright 2023 CasjaysDev
# @@Created          :  Mon Aug 28 06:48:42 PM EDT 2023
# @@File             :  05-custom.sh
# @@Description      :  script to install Deno
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# shellcheck shell=bash
# shellcheck disable=SC2016
# shellcheck disable=SC2031
# shellcheck disable=SC2120
# shellcheck disable=SC2155
# shellcheck disable=SC2199
# shellcheck disable=SC2317
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
set -o pipefail
[ "$DEBUGGER" = "on" ] && echo "Enabling debugging" && set -x$DEBUGGER_OPTIONS
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set env variables
exitCode=0
LANG_VERSION="${LANG_VERSION:-latest}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Predefined actions
echo "Installing Deno version: ${LANG_VERSION}"

# Install Deno
if [ "$LANG_VERSION" = "latest" ]; then
  echo "Installing latest Deno..."
  curl -fsSL https://deno.land/install.sh | sh || exitCode=1
else
  echo "Installing Deno v${LANG_VERSION}..."
  # Deno versions need v prefix and patch version
  curl -fsSL https://deno.land/install.sh | sh -s "v${LANG_VERSION}.0" || exitCode=1
fi

# Move to /usr/local/bin
if [ -f "$HOME/.deno/bin/deno" ]; then
  mv "$HOME/.deno/bin/deno" /usr/local/bin/deno || exitCode=1
  rm -rf "$HOME/.deno"
  echo "Deno installed successfully"
  deno --version || exitCode=1
else
  echo "Deno installation failed" >&2
  exitCode=1
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set the exit code
exit $exitCode
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ex: ts=2 sw=2 et filetype=sh
