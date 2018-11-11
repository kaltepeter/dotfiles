#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ "${k_custom_lib_loaded:-}" == true ]] || source "${__dir}/shell/lib.sh"

usage() {
	cat <<END
usage: set-hostname.sh <new hostname>

Set/change hostname on a system
Configures:

    new hostname: the desired hostname

    -h: show this help message
END
	exit 1
}

[[ ${1:-} ]] || error "<new hostname> is empty" 1
[[ ${2:-} ]] || error "<old hostname> is empty" 1

while getopts "h" opt; do
	case $opt in
	h)
		usage
		exit 0
		;;
	\?)
		exit 1
		;;
	esac
done

shift $((OPTIND - 1))
# old=$(hostname)
declare old="${2}"
declare new="${1}"

if [[ "${new}" == "${old}" ]]; then
	echo "[SKIP] ... hostname is already set to: ${new}."
	exit 0
else
	for file in \
		/etc/exim4/update-exim4.conf.conf \
		/etc/printcap \
		/etc/hostname \
		/etc/hosts \
		/etc/ssh/ssh_host_rsa_key.pub \
		/etc/ssh/ssh_host_dsa_key.pub \
		/etc/motd \
		/etc/ssmtp/ssmtp.conf; do
    echo "[CONFIG] ... replacing ${old} with ${new} in ${file}"
		[ -f ${file} ] && sed -i.old -e "s:${old}:${new}:g" ${file}
	done
fi

echo ''
exit 0
