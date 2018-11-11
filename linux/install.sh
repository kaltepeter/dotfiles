#!/usr/bin/env bash
# linux/install
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

usage() {
	cat <<END
usage: linux/install.sh <new hostname>

Set/change hostname on a system
Configures:

    new hostname: the desired hostname

    -h: show this help message
END
	exit 1
}

readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ "${k_custom_lib_loaded:-}" == true ]] || source "${__dir}/../shell/lib.sh"

[[ -z "${hostname:-}" ]] && error "env var hostname is required." 1

echo 'macosx/install.sh | ...'

# If we're on a Mac, let's install and setup homebrew.
if [[ $(uname -s) == "Linux" ]]; then
	echo "[INSTALL] .. installing linux specific stuff..."

  echo "[CONFIG] ... default editor"
	if update-alternatives --get-selections | grep -q '^editor.*vim'; then
		echo "[SKIP] ... vim is already the default editor."
	else
		sudo update-alternatives --set editor /usr/bin/vim.tiny
	fi

  echo "[CONFIG] ... hostname"
  sh -c "${__dir}/set-hostname.sh ${hostname} raspberrypi"

	# source "${__dir}/bootstrap.sh"
fi

echo ''
exit 0
