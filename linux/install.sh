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
usage: hostname=<new_hostname> machineuser=<machine_user> linux/install.sh

Intall linux defaults.
Configures:

    new_hostname: the desired hostname
    machine_user: the desired user login name

    -h: show this help message
END
	exit 1
}

[[ -z "${hostname:-}" ]] && error "env var hostname is required." 1
[[ -z "${machineuser:-}" ]] && error "env var machineuser is required." 1

echo 'linux/install.sh | ...'

# If we're on a linux system, let's install and setup homebrew.
if [[ $(uname -s) == "Linux" ]]; then
	echo "[INSTALL] .. installing linux specific stuff..."

	echo "[CONFIG] ... check for latest updates..."
	sudo apt-get update
	sudo apt-get upgrade

	echo "[CONFIG] ... hostname: ${hostname}"
	sh -c "${__dir}/set-hostname.sh \"${hostname}\""

  echo "[CONFIG] ... reconfigure ssh"
  sudo rm /etc/ssh/ssh_host*
  sudo dpkg-reconfigure openssh-server

	echo "[CONFIG] ... set locale/time/password/etc..."
	if env | grep -q 'LANG=en_US.UTF-8'; then
		echo "[SKIP] ... locale, language set"
	else
		sudo update-locale "LANG=en_US.UTF-8"
		sudo locale-gen --purge "en_US.UTF-8"
		sudo dpkg-reconfigure --frontend noninteractive locales
	fi
	if grep -q 'US/Central' /etc/timezone; then
		echo "[SKIP] ... timezone already set to US/Central"
	else
		sudo dpkg-reconfigure tzdata
	fi
	if grep -q 'XKBLAYOUT=us' /etc/default/keyboard; then
		echo "[SKIP] ... keyboard already set to us"
	else
		sudo localectl set-keymap us
		# TODO: find a better way to determine password setting and restart
		passwd
		shutdown -r now
	fi

	echo "[CONFIG] ... default editor"
	if update-alternatives --get-selections | grep -q '^editor.*vim'; then
		echo "[SKIP] ... vim is already the default editor."
	else
		sudo update-alternatives --set editor /usr/bin/vim.tiny
	fi

	echo "[CONFIG] ... disable auto login"
	lightdm_conf='/etc/lightdm/lightdm.conf'
	if grep -q 'autologin-user= ' ${lightdm_conf}; then
		echo "[SKIP] ... autologin is already disabled."
	else
		sudo sed -i.old -e 's:autologin-user=.*:autologin-user= :g' ${lightdm_conf}
	fi
	# sudo systemctl disable serial-getty@ttyAMA0.service

	echo "[CONFIG] ... remove no password for sudo overrides"
	find /etc/sudoers.d/ -maxdepth 1 -type f ! -name 'README' ! -name '.*~' -exec sudo mv '{}' '{}~' \;

	echo "[CONFIG] ... disable graphical startup. run startx to start gui."
	sudo systemctl set-default multi-user.target
	sudo ln -fs /etc/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service

	echo "[CONFIG] ... disable pi bg"
	if grep -q '#default-user-image=' /etc/lightdm/pi-greeter.conf; then
		echo "[SKIP] ... pi bg already disabled"
	else
		sudo sed -i.old -e 's:default-user-image=:#default-user-image=:g' /etc/lightdm/pi-greeter.conf
	fi

  echo "[CONFIG] ... add config.txt customizations"
  custom_config_file='/boot/config.txt'
  if grep -q "##### k custom settings" "${custom_config_file}"; then
    custom_settings_version=$(grep 'k custom settings v.' "${__dir}/config.txt" | sed 's:##### k custom settings v. \(.*\) #####:\1:')
    custom_settings_current_version=$(grep 'k custom settings v.' "${custom_config_file}" | sed 's:##### k custom settings v. \(.*\) #####:\1:')
    if [[ "${custom_settings_current_version}" == "${custom_settings_version}" ]]; then
      echo "[SKIP] ... config.txt already set."
    else
      echo "[UDPATE] ... config.txt is being updated."
      sudo sh -c "sed -i'' '/##### k custom settings/,/end #####/d' ${custom_config_file}"
      sudo sh -c "cat ${__dir}/config.txt >> ${custom_config_file}"
    fi
  else
    sudo sh -c "cat ${__dir}/config.txt >> ${custom_config_file}"
  fi

  # echo "[CREATE] ... new user"
  # if id -u "${machineuser}" | grep -q 'no such user'; then
  #   sudo adduser "${machineuser}"
  #   sudo adduser "${machineuser}" sudo
  #   # verify sudo access
  #   su -c "${machineuser}"
  #   sudo su
  #   exit
  #   echo "logged in as: $(whoami)"
  # else
  #   echo "[SKIP] ... user ${machineuser} already exists."
  # fi

	# source "${__dir}/bootstrap.sh"
fi

echo ''
exit 0
