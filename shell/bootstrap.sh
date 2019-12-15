#!/usr/bin/env bash
# shell/bootstrap

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/lib.sh"

# symlink custom scripts
status "${BASH_SOURCE[0]} | ..."

typed_message 'COPY' "copying scripts to local bin"

ln -s "${__dir}"/scripts/* /usr/local/bin

echo ""
exit 0
