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

# from: https://github.com/holman/dotfiles/blob/master/homebrew/install.sh
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

if test "$(uname)" = "Darwin"; then
  # Check for Homebrew
  if test ! "$(command -v brew)"; then
    typed_message 'INSTALL' "Homebrew"

    # Install the correct homebrew for each OS type
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    # elif test [[ substr "$(uname -s)" 1 5 = "Linux" ]]; then
    # 	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
  else
    typed_message 'SKIP' "brew already installed."
    typed_message 'INSTALL' "Updating and cleaning brew."
    update_brew
    brew --version
  fi

  echo ''

  xcode-select --install || typed_message 'SKIP' 'xcode already installed. Use softwareupdate.'
  sh -c "${__dir}/brew.sh"
else
  typed_message 'SKIP' "Brew. Not a Mac."
fi

exit 0
