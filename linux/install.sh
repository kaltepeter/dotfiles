#!/usr/bin/env bash
# linux/install
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ "${k_custom_lib_loaded:-}" == true ]] || source "${__dir}/../shell/lib.sh"

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

[[ -z "${hostname:-}" ]] && error "env var hostname is required." 1

echo 'macosx/install.sh | ...'

# If we're on a Mac, let's install and setup homebrew.
if [[ $(uname -s) == "Linux" ]]; then
	echo "[INSTALL] .. installing linux specific stuff..."

  # echo "[CONFIG] ... check for latest updates..."
  # sudo apt-get update
  # sudo apt-get upgrade

  echo "[CONFIG] ... default editor"
	if update-alternatives --get-selections | grep -q '^editor.*vim'; then
		echo "[SKIP] ... vim is already the default editor."
	else
		sudo update-alternatives --set editor /usr/bin/vim.tiny
	fi

  echo "[CONFIG] ... hostname"
  sh -c "${__dir}/set-hostname.sh ${hostname} raspberrypi"

  echo "[CONFIG] ... disable auto login"
  lightdm_conf='/etc/lightdm/lightdm.conf'
  if grep -q 'autologin-user= ' ${lightdm_conf}; then
    echo "[SKIP] ... autologin is already disabled."
  else
    sudo sed -i.old -e 's:autologin-user=.*:autologin-user= :g' ${lightdm_conf}
  fi

  echo "[CONFIG] ... remove no password for sudo overrides"
  find /etc/sudoers.d/ -maxdepth 1 -type f ! -name 'README' ! -name '.*~' -exec sudo mv '{}' '{}~' \;
	# source "${__dir}/bootstrap.sh"
fi

echo ''
exit 0
