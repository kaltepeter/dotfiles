#!/usr/bin/env bash
#
# ruby/bootstrap

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"

status "${BASH_SOURCE[0]} | ..."

typed_message 'CONFIG' "Configure global gems."

rb_version=$(rvm list | grep 'ruby-' | sed 's/ruby-\([0-9\.]*\)\ .*/\1/')

rvm alias create default "${rb_version//\ }"
rvm list
# shellcheck disable=SC1010
rvm @global do gem install bundler
# shellcheck disable=SC1010
rvm @global do gem install rubocop
# shellcheck disable=SC1010
rvm @global do gem install solargraph

echo ""
exit 0
