#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace
readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"

typed_message 'CONFIG' "check for latest updates..."
sudo apt-get update
sudo apt-get upgrade

if ! command -v zsh; then
	sudo apt-get install zsh
fi

# TODO: purge and clean apt-get

echo ''
exit 0
