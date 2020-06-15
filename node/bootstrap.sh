#!/usr/bin/env bash
# git/bootstrap

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__cur_dir=$(pwd)

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"

typed_message 'CONFIG' "Configure global node."
# auto merge node lock files
npx npm-merge-driver install --global
npm i --global npm-merge-driver

