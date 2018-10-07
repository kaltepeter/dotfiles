#!/usr/bin/env bash
# system/install

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

echo 'system/install.sh | ...'

echo "[CREATE] ... sshkeys for ${email} on $(hostname)"
# ssh-keygen -t rsa -b 4096 -C "${email}" -N '' -f "${HOME}/.ssh/id_rsa"

echo ''
exit 0