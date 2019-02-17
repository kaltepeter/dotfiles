#!/usr/bin/env bash
# zsh/install

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo 'zsh/install.sh | ...'

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "[CONFIG] ... material theme"

declare zsh_custom_dir="${HOME}/.oh-my-zsh/custom"
declare material_theme_dir="${zsh_custom_dir}/themes"
if [[ -d "${material_theme_dir}" ]]; then
	echo "[SKIP] ... ${material_theme_dir} already exists."
else
	echo "[CREATE] ... ${material_theme_dir}"
	mkdir "${material_theme_dir}"
fi

materialshell_theme="${material_theme_dir}/materialshell.zsh-theme"
if [[ -L "${materialshell_theme}" ]]; then
	echo "[SKIP] ... ${materialshell_theme} is already linked."
elif [[ -e "${materialshell_theme}" ]]; then
	echo "[FAIL] ... ${materialshell_theme} already exists. delete to relink."
else
	ln -s "${__dir}/../materialshell/materialshell.zsh" "${materialshell_theme}"
fi

declare -a zsh_configs=('config.zsh')

for config in "${zsh_configs[@]}"; do
	if [[ -L "${zsh_custom_dir}/${config}" ]]; then
		echo "[SKIP] ... ${zsh_custom_dir}/${config} is already linked."
	elif [[ -e "${zsh_custom_dir}/${config}" ]]; then
		echo "[FAIL] ... ${config} already exists. delete to relink."
	else
		ln -s "${__dir}/${config}" "${zsh_custom_dir}/"
	fi
done

echo ''
exit 0
