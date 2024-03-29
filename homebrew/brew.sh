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

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils

# Install Bash 4.
brew install bash
brew install bash-completion2

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells
#  chsh -s "${BREW_PREFIX}/bin/bash";
fi

# install python deps
brew install pyenv
brew install pyenv-virtualenv

# Install more recent versions of some macOS tools.
brew install vim
brew install grep
brew install openssh
brew install screen

# install zsh
brew install zsh
brew install zsh-completions

# Switch to using brew-installed zsh as default shell
if ! grep -Fq "${BREW_PREFIX}/bin/zsh" /etc/shells; then
  echo "${BREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells
  chsh -s "${BREW_PREFIX}/bin/zsh"
fi

# taps
brew tap homebrew/cask-fonts
# brew tap sambadevi/powerlevel9k
brew tap mongodb/brew
brew tap azure/functions

brew install ffmpeg
brew install gifsicle

# Install other useful binaries.
brew install git
brew install git-lfs

brew install openssl

brew install docker

# http proxy
brew install mitmproxy

brew install shellcheck

brew install mas

brew install node

brew install hub

brew install mongodb-community

brew install cloudfoundry/tap/cf-cli

brew install rabbitmq

brew install azure-cli

brew install gnupg2

brew install azure-functions-core-tools@3

brew install git-secrets

brew install derailed/k9s/k9s

# theme
# brew install powerlevel9k

# mac osc apps
cask_list_installed=($(brew list --cask))
cask_list=(
  'balenaetcher'
  'brave-browser'
  'charles'
  'evernote'
  'font-fira-code-nerd-font'
  'font-fira-mono-nerd-font'
  'font-hack-nerd-font'
  'google-chrome'
  'gitkraken'
  'jetbrains-toolbox'
  'ngrok'
  'numi'
  'p4v'
  'postman'
  'slack'
  'studio-3t'
  'sublime-text'
  'virtualbox'
  'virtualbox-extension-pack'
  'visual-studio-code'
  'wireshark'
  'xquartz' #dependency for gifsicle, only required for mountain-lion and above
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
