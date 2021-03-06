#!/usr/bin/env bash
#
# node/bootstrap

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"

status "${BASH_SOURCE[0]} | ..."

typed_message 'INSTALL' "node"
# Doesn't work with bash and zsh. TODO: fix it
nvm install node
nvm install 12

typed_message 'CONFIG' "Configure global node."
# auto merge node lock files
npx npm-merge-driver install --global
npm i --global npm-merge-driver

echo ""
exit 0
