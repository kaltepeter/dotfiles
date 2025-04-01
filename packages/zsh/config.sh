#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)/.."
CI=${CI:-false}

# shellcheck disable=SC1091
[[ $(command -v k_custom_lib_loaded) ]] || source "${__root}/shell/lib.sh"

if [[ ${CI} == false ]]; then
  trap inner_end EXIT 
fi

configure_themes() {
  custom_theme_dir="${ZSH_CUSTOM}/themes}"

  if [[ -d "${custom_theme_dir}" ]]; then
    typed_message 'SKIP' "${custom_theme_dir} already exists."
  else
    typed_message 'CREATE' "${custom_theme_dir}"
    mkdir "${custom_theme_dir}"
  fi

  declare -a zsh_themes=("materialshell/materialshell.zsh-theme" "powerlevel10k")

  for theme in "${zsh_themes[@]}"; do
    if [[ -L "${custom_theme_dir}/${theme##[a-zA-Z]*/}" ]]; then
      typed_message 'SKIP' "${custom_theme_dir}/${theme} is already linked."
    elif [[ -e "${custom_theme_dir}/${theme}" ]]; then
      typed_message 'FAIL' "${custom_theme_dir}/${theme} already exists. delete to relink."
    else
      ln -s "${__root}/${theme}" "${custom_theme_dir}/${theme##[a-zA-Z]*/}"
    fi
  done
}

configure_zsh_custom_configs() {
  # declare -a zsh_configs=('0-vars.zsh' 'config.zsh' 'powerlevel9k.zsh' 'alias.zsh')
  declare -a zsh_configs=('config.zsh' 'powerlevel10k.zsh' 'alias.zsh')

  for config in "${zsh_configs[@]}"; do
    if [[ -L "${ZSH_CUSTOM}/${config}" ]]; then
      typed_message 'SKIP' "${ZSH_CUSTOM}/${config} is already linked."
    elif [[ -e "${ZSH_CUSTOM}/${config}" ]]; then
      typed_message 'FAIL' "${config} already exists. delete to relink."
    else
      ln -s "${__dir}/${config}" "${ZSH_CUSTOM}/"
    fi
  done
}

# Oh-My-Zsh
# typed_message 'CONFIG' "POETRY"
# mkdir "${ZSH}/plugins/poetry"
# poetry completions zsh > "${ZSH}/plugins/poetry/_poetry"

if [[ ${CI} == false ]]; then
  inner_header
  configure_themes 
  configure_zsh_custom_configs

  echo ''
  exit 0
fi