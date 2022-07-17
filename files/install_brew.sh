#!/usr/bin/env bash
#
# homebrew/install

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"

status "${BASH_SOURCE[0]} | ..."

if test "$(uname)" = "Darwin"; then
  if test ! "$(command -v brew)"; then
    typed_message 'INSTALL' "Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    typed_message 'SKIP' "brew already installed."
    brew --version
  fi
  echo ''
else
  typed_message 'SKIP' "Brew. Not a Mac."
fi

exit 0
