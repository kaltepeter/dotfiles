#!/usr/bin/env bash
#
# ruby/install

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"

status "${BASH_SOURCE[0]} | ..."

# from: https://rvm.io/
#
# RVM ruby version manager

if test ! "$(command -v rvm)"; then
  typed_message 'INSTALL' "rvm"
  gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  curl -sSL https://get.rvm.io | bash -s stable --auto-dotfiles

  # shellcheck disable=SC1090
  source "${HOME}/.rvm/scripts/rvm"

  typed_message 'INSTALL' "latest ruby"
  rvm install ruby --latest

  exec -l "$SHELL"
else
  typed_message 'SKIP' "rvm already installed."
  rvm -v
  typed_message 'INSTALL', "Updating rvm"
  rvm get stable --auto-dotfiles
fi

echo ''

exit 0
