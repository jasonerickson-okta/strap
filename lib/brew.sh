#!/usr/bin/env bash

set -Eeuo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
if ! command -v strap::lib::import >/dev/null; then
  echo "This file is not intended to be run or sourced outside of a strap execution context." >&2
  [[ "${BASH_SOURCE[0]}" != "${0}" ]] && return 1 || exit 1 # if sourced, return 1, else running as a command, so exit
fi

strap::lib::import lang || . lang.sh
strap::lib::import logging || . logging.sh
strap::lib::import path || . path.sh
strap::lib::import xcodeclt || . xcodeclt.sh

STRAP_HOME="${STRAP_HOME:-}" && strap::assert::has_length "$STRAP_HOME" 'STRAP_HOME is not set.'
STRAP_USER_HOME="${STRAP_USER_HOME:-}" && strap::assert::has_length "$STRAP_USER_HOME" 'STRAP_USER_HOME is not set.'

set -a

strap::brew::init() {

  # Ensure Xcode Command Line Tools are installed
  strap::xcode::clt::ensure
  strap::xcode::clt::ensure_license

  strap::running "Checking Homebrew"
  if command -v brew >/dev/null 2>&1; then
    strap::ok
    strap::running "Checking Homebrew updates"
    brew update >/dev/null
    brew upgrade
    strap::ok
    strap::running "Ensuring Homebrew cleanup"
    brew cleanup >/dev/null
  else
    strap::action "Installing Homebrew"
    (
      set +o pipefail
      set +e
      unset -f $(compgen -A function strap) # homebrew scripts barf when 'strap::' function names are present
      yes '' | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      homebrew_exit_code="$?"
      set -o pipefail
      set -e
      if [[ "$homebrew_exit_code" -ne 0 ]]; then echo "Homebrew installation failed." >&2; exit 1; fi
    )
  fi

  strap::action "determining Homebrew prefix"
  local osArch=$(uname -p)
  export STRAP_HOMEBREW_PREFIX='/usr/local'

  if [[ "${osArch}" == "arm" ]]; then
    export STRAP_HOMEBREW_PREFIX='/opt/homebrew'
    strap::running "arch: $(uname -p). using homebrew prefix $STRAP_HOMEBREW_PREFIX "
  else
    strap::running "arch: $(uname -p). using default homebrew prefix: $STRAP_HOMEBREW_PREFIX"
  fi

  eval $(${STRAP_HOMEBREW_PREFIX}/bin/brew shellenv) && echo "Using Homebrew - $(brew --version)"
  strap::ok

  STRAP_HOMEBREW_PREFIX="$(brew --prefix)"
  strap::path::contains "${STRAP_HOMEBREW_PREFIX}/sbin" || export PATH="${STRAP_HOMEBREW_PREFIX}/sbin:${PATH}"
  strap::path::contains "${STRAP_HOMEBREW_PREFIX}/bin" || export PATH="${STRAP_HOMEBREW_PREFIX}/bin:${PATH}"

  strap::running "Ensuring Homebrew \$PATH entries"
  local filename="100.homebrew.sh"
  local src="${STRAP_HOME}/etc/straprc.d/$filename"
  [[ ! -f "$src" ]] && strap::abort "Invalid strap installation. Missing file: $src"
  local dest="${STRAP_USER_HOME}/etc/straprc.d/$filename"
  rm -rf "$dest" # remove any old copy that might be there to ensure we get the latest
  cp "$src" "$dest"
  strap::ok
}

strap::brew::pkg::is_installed() {
  local formula="${1:-}" && strap::assert::has_length "$formula" '$1 must be the formula id'
  brew list --versions "$formula" >/dev/null
}

strap::brew::pkg::install() {
  local formula="${1:-}" && strap::assert::has_length "$formula" '$1 must be the formula id'
  brew install "$formula"
}

set +a