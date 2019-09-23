#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"

[[ -z "${1:-}" ]] && error "<new hostname> is empty" 1

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
old=$(hostname)
declare new="${1}"

if [[ "${new}" == "${old}" ]]; then
	typed_message 'SKIP' "hostname is already set to: ${new}."
	exit 0
else
	for file in \
		/etc/exim4/update-exim4.conf.conf \
		/etc/printcap \
		/etc/hostname \
		/etc/hosts \
		/etc/ssh/ssh_host_rsa_key.pub \
		/etc/ssh/ssh_host_dsa_key.pub \
		/etc/ssh/ssh_host_ecdsa_key.pub \
		/etc/ssh/ssh_host_ed25519_key.pub \
		/etc/ssmtp/ssmtp.conf; do
		if [[ -f ${file} ]]; then
		  typed_message 'CONFIG' "replacing ${old} with ${new} in ${file}"
			sudo sed -i.old -e "s:${old}:${new}:g" ${file}
		fi
	done
fi

echo ''
exit 0
