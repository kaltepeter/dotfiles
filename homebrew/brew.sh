#!/usr/bin/env bash
# homebrew/brew.sh
set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

status "${BASH_SOURCE[0]} | ..." | tee -a "${log_file}"

# modified from: https://github.com/mathiasbynens/dotfiles/blob/master/brew.sh

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update | tee -a "${log_file}"

# Upgrade any already-installed formulae.
brew upgrade | tee -a "${log_file}"

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
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
#  chsh -s "${BREW_PREFIX}/bin/bash";
fi;

# install python deps
brew install pyenv

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
  echo "${BREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/zsh";
fi;

# Install other useful binaries.
brew install git
brew install git-lfs

brew install openssl

brew install docker

# http proxy
brew install mitmproxy

brew install shellcheck

# mac osc apps
brew cask install google-chrome || echo 'google-chrome failed.'
brew cask install sublime-text || echo 'sublime failed.'
brew cask install jetbrains-toolbox || echo 'jetbrains-toolbox failed.'
brew cask install docker || echo 'docker failed.'
brew cask install brave-browser || echo 'brave-browser failed.'
brew cask install slack || echo 'slack failed.'
brew cask install visual-studio-code || echo 'visual-studio-code failed.'
brew cask install virtualbox || echo 'virtualbox failed.'
brew cask install wireshark || echo 'wireshark failed.'
brew cask install charles || echo 'charles failed.'
brew cask install gitkraken || echo 'gitkraken failed.'


# Remove outdated versions from the cellar.
brew cleanup | tee -a "${log_file}"

echo ''
exit 0
