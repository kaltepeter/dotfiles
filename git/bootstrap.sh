#!/usr/bin/env bash
# git/bootstrap

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

echo 'git/bootstrap.sh | ...'


echo "[CONFIG] ... verify github.com and add to known hosts"

declare github_fingerprint="$(ssh-keyscan github.com | ssh-keygen -lf -)"
echo "github_fingerprint: ${github_fingerprint}"

if [[ $(echo ${github_fingerprint} | grep -e 'SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8' \
	 -e '16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48') ]]; then
	echo "[VERIFY] ... fingerprint"
else
	echo "[FAIL] ... could not verify fingerprint"
	exit 1
fi

echo ''
exit 0