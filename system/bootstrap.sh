#!/usr/bin/env bash
# system/bootstrap

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

status "${BASH_SOURCE[0]} | ..."

declare rsa_private_key_file="${HOME}/.ssh/id_rsa"

if [[ -e "${rsa_private_key_file}" ]]; then
	typed_message 'SKIP' "${rsa_private_key_file} already exists."
else
	typed_message 'CREATE' "sshkeys for ${email} on $(hostname)"
	ssh-keygen -t rsa -b 4096 -C "${email}" -f "${rsa_private_key_file}"
	eval "$(ssh-agent -s)"
	/usr/bin/ssh-add -K "${rsa_private_key_file}"
fi

echo ''
exit 0
