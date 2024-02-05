#!/usr/bin/env bash
# zsh/configure-vars

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"

status "${BASH_SOURCE[0]} | ..."

typed_message 'CONFIG' "configure vars"

declare -a vars_list=('CONVENTIONAL_GITHUB_RELEASER_TOKEN' 'HUE_API_TOKEN' 'HUE_IP')
declare vars_file="${__dir}/0-vars.zsh"

if [[ ! -f "${vars_file}" ]]; then
	touch "${vars_file}"
fi

for var_name in "${vars_list[@]}"; do
	if grep -q "${var_name}=" "${vars_file}"; then
		typed_message 'SKIP' "${var_name} already exists."
	else
    echo "${var_name}=${!var_name}" >> "${vars_file}"
	fi
done

echo ''
exit 0
