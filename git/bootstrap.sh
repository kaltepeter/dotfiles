#!/usr/bin/env bash
# git/bootstrap

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__cur_dir=$(pwd)

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"

cd "${__dir}/.."

python -m git.update-ssh-key

cd "${__cur_dir}"

status "${BASH_SOURCE[0]} | ..."

typed_message 'CONFIG' "verify github.com and add to known hosts"

declare github_fingerprint="$(ssh-keyscan github.com | ssh-keygen -lf -)"

typed_message 'VERIFY' "github_fingerprint: ${github_fingerprint}"

github_ssh_test() {
	ssh -T -o StrictHostKeyChecking=accept-new git@github.com 2>&1
}

if [[ $(echo ${github_fingerprint} | grep -e 'SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8' \
	 -e '16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48') ]]; then
	typed_message 'CREATE' "github.com > knownhosts"
	typed_message 'VERIFY' "ssh to github.com"
	declare github_ssh_test_out="$(github_ssh_test)"

	if [[ $(echo "${github_ssh_test_out}" | grep "You've successfully authenticated") ]]; then
		typed_message 'SUCCESS' "connected to github"
	else
		error "failed to conenct to github ssh" 1
	fi
else
	error "could not verify fingerprint" 1
fi

typed_message 'CONFIG' "Adding gpg keys"

gpg --list-secret-keys --keyid-format LONG
read -r -e -i "n" -p "Do you need to generate a gpg key? [y|n] (default n):" generate_gpg_key

if [[ "${generate_gpg_key}" == 'y' ]]; then
  gpg --full-generate-key
fi

gpg --list-secret-keys --keyid-format LONG
read -r -p 'Enter ID of gpg key for github: ' github_gpg
git config --global user.signingkey "${github_gpg}"
git config --global commit.gpgsign true
typed_message 'INFO' 'Download gpg tools'
open 'https://gpgtools.org/'

typed_message 'CONFIG' "Configure git globally"

git config --global diff.tool p4merge
git config --global diff.tool.p4merge.path "$(command -v p4merge)"

git config --global merge.tool p4merge
git config --global mergetool.p4merge.path "$(command -v p4merge)"

git config --global mergetool.keepBackup false

read -r -p "github user full name: " github_user_name
git config --global user.name "${github_user_name}"
read -r -p "github email: " github_email
git config --global user.email "${github_email}"


echo ''
exit 0
