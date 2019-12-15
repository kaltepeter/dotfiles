#!/usr/bin/env bash
# zsh/install

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"
status "${BASH_SOURCE[0]} | ..."

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || typed_message 'SKIP' 'oh-my-zsh already installed.'

typed_message 'CONFIG' "material theme"

declare zsh_custom_dir="${HOME}/.oh-my-zsh/custom"
declare custom_theme_dir="${zsh_custom_dir}/themes"
if [[ -d "${custom_theme_dir}" ]]; then
	typed_message 'SKIP' "${custom_theme_dir} already exists."
else
	typed_message 'CREATE' "${custom_theme_dir}"
	mkdir "${custom_theme_dir}"
fi

declare -a zsh_themes=("materialshell/materialshell.zsh-theme" "powerlevel9k")

for theme in "${zsh_themes[@]}"; do
  if [[ -L "${custom_theme_dir}/${theme##[a-zA-Z]*/}" ]]; then
    typed_message 'SKIP' "${custom_theme_dir}/${theme} is already linked."
  elif [[ -e "${custom_theme_dir}/${theme}" ]]; then
    typed_message 'FAIL' "${custom_theme_dir}/${theme} already exists. delete to relink."
  else
    ln -s "${__dir}/../${theme}" "${custom_theme_dir}/${theme##[a-zA-Z]*/}"
  fi
done

declare -a zsh_configs=('config.zsh' 'powerlevel9k.zsh' 'alias.zsh')

for config in "${zsh_configs[@]}"; do
	if [[ -L "${zsh_custom_dir}/${config}" ]]; then
		typed_message 'SKIP' "${zsh_custom_dir}/${config} is already linked."
	elif [[ -e "${zsh_custom_dir}/${config}" ]]; then
		typed_message 'FAIL' "${config} already exists. delete to relink."
	else
		ln -s "${__dir}/${config}" "${zsh_custom_dir}/"
	fi
done

echo ''
exit 0
