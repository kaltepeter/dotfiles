#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)/.."
CI=${CI:-false}
BREW_PREFIX=$(brew --prefix)

# shellcheck disable=SC1091
[[ $(command -v k_custom_lib_loaded) ]] || source "${__root}/shell/lib.sh"

if [[ ${CI} == false ]]; then
  trap inner_end EXIT 
fi

update_shells() {
  if command -v brew > /dev/null; then
    # adding shells
    if ! grep -F --quiet "${BREW_PREFIX}/bin/bash" /etc/shells; then
      typed_message 'CONFIG' 'Adding bash to shells'
      echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells
    fi

    # add zsh and Switch to using brew-installed zsh as default shell
    if ! grep -F --quiet "${BREW_PREFIX}/bin/zsh" /etc/shells; then
      typed_message 'CONFIG' 'Adding zsh to shells and setting as default shell.'
      echo "${BREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells
      # default shell in mac is zsh
      chsh -s "${BREW_PREFIX}/bin/zsh"
    fi
  fi
}

configure_bashrc() {
  if [[ -z "${1:-}" ]]; then
    error "Bash profile not provded, first argument must be a bash profile"
  fi
  
  bash_profile="${1:-}"
  bash_line="[[ -r \"${BREW_PREFIX}/etc/profile.d/bash_completion.sh\" ]] && . \"${BREW_PREFIX}/etc/profile.d/bash_completion.sh\""
  touch "${bash_profile}"
  if ! grep --fixed-strings --quiet "${bash_line}" "${bash_profile}"; then
    typed_message 'CONFIG' "Adding shell completions to ${bash_profile}."
    echo "${bash_line}" >> "${bash_profile}"
  fi
}

configure_zshrc() {
  if [[ -z "${1:-}" ]]; then
    error "ZSH profile not provded, first argument must be a zsh profile"
  fi

  zsh_profile="${1:-}"
  completion_string() { 
    cat << EOF
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:\$FPATH

  autoload -Uz compinit
  compinit
fi
EOF
  }

  ngrok_string() {
    cat << EOF
if command -v ngrok &>/dev/null; then
  eval "\$(ngrok completion)"
fi
EOF
  }

  touch "${zsh_profile}"
  if ! grep --quiet "PATH=${HOMEBREW_PREFIX}/share/zsh-completions:" "${zsh_profile}"; then
    typed_message 'CONFIG' "Adding shell completions to ${zsh_profile}."
    completion_string >> "${zsh_profile}"
  fi

  if ! grep --quiet 'ngrok completion' "${zsh_profile}"; then
    typed_message 'CONFIG' "Adding ngrok completions to ${zsh_profile}."
    ngrok_string >> "${zsh_profile}"
  fi

  chmod go-w "${HOMEBREW_PREFIX}/share"
  chmod -R go-w "${HOMEBREW_PREFIX}/share/zsh"
}

configure_gitlfs() {
  if ! command -v git lfs > /dev/null; then
    typed_message 'CONFIG' "Installing git lfs."
    git lfs install
  fi
}

install_rosetta() {
  softwareupdate --install-rosetta --agree-to-license
}

install_oh_my_zsh() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || typed_message 'SKIP' 'oh-my-zsh already installed.'
}

# typed_message 'INFO' "Adding taps."
# brew tap mongodb/brew

if [[ ${CI} == false ]]; then
  inner_header
  update_shells
  configure_bashrc "${HOME}/.bashrc"
  # TODO: convert zsh completions to oh my zsh
  configure_zshrc "${HOME}/.zshrc"
  install_oh_my_zsh
  configure_gitlfs
  install_rosetta

  echo ''
  exit 0
fi