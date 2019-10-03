#!/usr/bin/env bash
# vim/bootstrap

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"

log_file="${log_file:-/dev/null}"

status "${BASH_SOURCE[0]} | ..."

typed_message 'CONFIG' "Copying vim config"

cp "${__dir}/.vimrc" "${HOME}/" | tee -a "${log_file}"

echo ""
exit 0
