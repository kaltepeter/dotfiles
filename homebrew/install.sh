#!/usr/bin/env bash
# homebrew/install.sh
set -o errexit
set -o pipefail
set -o nounset
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" 
__root="$(pwd)"
__base="$(basename "${BASH_SOURCE[0]}" .sh)"
local_path="${__dir//${__root}\/}"
log_file="${__root}/logs/${local_path//\//_}_${__base}.log"
script_name="${local_path}/$(basename "${BASH_SOURCE[0]}")"
brew_caveats_log="${__root}/logs/brew_caveats.log"

DEBUG=${DEBUG:-0}
((${DEBUG} >= 1)) && set -o xtrace;
((${DEBUG} >= 2)) && set -o verbose;
exec 3>&2 > >(tee "${log_file}") 2>&1

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__root}/shell/lib.sh"
trap end EXIT 

date_header

typed_message 'UPDATE' "Updating homebrew."
brew update
typed_message 'UPDATE' "Updating homebrew packages."
brew upgrade

typed_message 'INFO' "Adding taps."
brew tap mongodb/brew

# modified from: https://github.com/mathiasbynens/dotfiles/blob/master/brew.sh
typed_message 'INSTALL' "Homebrew core packages"
# cat "${__dir}/core.txt" | grep '^- ' | sed 's/^- //' | xargs -I {} brew install \{\}
cat "${__dir}/core.txt" | grep '^- ' | sed 's/^- //' | while read -r formula; do
  if ! brew list --formula --versions "${formula}"; then
    brew install "${formula}"
  fi
done

typed_message 'INSTALL' "Homebrew core cask packages"
# cat "${__dir}/core-casks.txt" | grep '^- ' | sed 's/^- //' | xargs -I {} brew install --cask \{\}
cat "${__dir}/core-casks.txt" | grep '^- ' | sed 's/^- //' | while read -r formula; do
  if ! brew list --cask --versions "${formula}"; then
    brew install --cask "${formula}"
  fi
done


typed_message 'INFO' "Brew Caveats"
awk '/^==> Caveats/{print "\n-----\n";p=1;next} /^==>/{p=0} p' "${log_file}" > "${brew_caveats_log}"
typed_message 'INSTRUCTION' "Check the output of ${brew_caveats_log} each block is separated by -----. Many will have been run, use this if something isn't working."

bash_line="[[ -r \"/opt/homebrew/etc/profile.d/bash_completion.sh\" ]] && . \"/opt/homebrew/etc/profile.d/bash_completion.sh\""
touch ~/.bash_profile
if ! fgrep --quiet "${bash_line}" ~/.bash_profile; then
  typed_message 'CONFIG' "Adding bash completions to bash profile."
  echo "${bash_line}" >> ~/.bash_profile
fi

if ! command -v git lfs > /dev/null; then
  typed_message 'CONFIG' "Installing git lfs."
  git lfs install
fi

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# adding shells
if ! fgrep --quiet "${BREW_PREFIX}/bin/bash" /etc/shells; then
  typed_message 'CONFIG' "Adding bash to shells"
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells
#  chsh -s "${BREW_PREFIX}/bin/bash";
fi

# add zsh and Switch to using brew-installed zsh as default shell
if ! fgrep --quiet "${BREW_PREFIX}/bin/zsh" /etc/shells; then
  typed_message 'CONFIG' "Adding zsh to shells and setting as default shell."
  echo "${BREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells
  chsh -s "${BREW_PREFIX}/bin/zsh"
fi

# wrap up ffmpeg setup: https://gist.github.com/dergachev/4627207
# open "$(command -v XQuartz)" # runs the XQuartz installer (YOU NEED TO UPDATE THE PATH)

# Remove outdated versions from the cellar.
brew cleanup 

# start services
# brew services start mongodb-community

exit 0
