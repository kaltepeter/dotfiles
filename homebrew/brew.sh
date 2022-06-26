#!/usr/bin/env bash
# homebrew/brew.sh
set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"

status "${BASH_SOURCE[0]} | ..."

# modified from: https://github.com/mathiasbynens/dotfiles/blob/master/brew.sh

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells
#  chsh -s "${BREW_PREFIX}/bin/bash";
fi

# Switch to using brew-installed zsh as default shell
if ! grep -Fq "${BREW_PREFIX}/bin/zsh" /etc/shells; then
  echo "${BREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells
  chsh -s "${BREW_PREFIX}/bin/zsh"
fi

# taps
# brew tap sambadevi/powerlevel9k
brew tap azure/functions

brew install docker

brew install mas

brew install node

brew install rabbitmq

brew install azure-cli

brew install azure-functions-core-tools@3

# theme
# brew install powerlevel9k

# mac osc apps
cask_list_installed=($(brew list --cask))
cask_list=(
  'virtualbox'
  'virtualbox-extension-pack'
)
for item in ${cask_list[*]}; do
  if [[ $(echo "${cask_list_installed[@]}" | grep -o "${item}") ]]; then
    typed_message 'SKIP' "${item} is already installed."
    # upgrade if possible

  else
    typed_message 'INSTALL' "Installing ${item}"
    if [[ "${item}" == 'virtualbox' ]]; then
      # read -p "see https://developer.apple.com/library/archive/technotes/tn2459/_index.html about how to approve virtualbox kext to continue. press [enter]"
      echo "Due to apple security update virtualbox may fail: see https://developer.apple.com/library/archive/technotes/tn2459/_index.html and approve when it asks for password."
      osascript "${__dir}/../macosx/script/show_security_settings.applescript"
      read -p "If the security window needs approval, wait for the preferences to load and approve. [enter] to contine."
    fi
    brew install --cask "${item}"
  fi
done

# wrap up ffmpeg setup: https://gist.github.com/dergachev/4627207
open "$(command -v XQuartz)" # runs the XQuartz installer (YOU NEED TO UPDATE THE PATH)

# Remove outdated versions from the cellar.
brew cleanup | tee -a "${log_file}"

# start services
brew services start mongodb-community

echo ''
exit 0
