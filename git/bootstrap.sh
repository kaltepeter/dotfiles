#!/usr/bin/env bash
# git/bootstrap

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sh -c "${__dir}/update-ssh-key.py"

echo 'git/bootstrap.sh | ...'

echo "[CONFIG] ... verify github.com and add to known hosts"

declare github_fingerprint="$(ssh-keyscan github.com | ssh-keygen -lf -)"

echo "[VERIFY] ... github_fingerprint: ${github_fingerprint}"

github_ssh_test() {
	ssh -T -o StrictHostKeyChecking=accept-new git@github.com 2>&1
}

if [[ $(echo ${github_fingerprint} | grep -e 'SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8' \
	 -e '16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48') ]]; then
	echo "[CREATE] ... github.com > knownhosts"
	echo "[VERIFY] ... ssh to github.com"
	declare github_ssh_test_out="$(github_ssh_test)"

	if [[ $(echo "${github_ssh_test_out}" | grep "You've successfully authenticated") ]]; then
		echo "[SUCCESS] ... connected to github" 
	else
		echo "[FAIL] ... failed to conenct to github ssh"
	fi
else
	echo "[FAIL] ... could not verify fingerprint"
	exit 1
fi

echo ''
exit 0