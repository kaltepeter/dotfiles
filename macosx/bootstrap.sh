#!/usr/bin/env bash
#
# macosx/bootstrap.sh

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ "${k_custom_lib_loaded:-}" == true ]] || source "${__dir}/../shell/lib.sh"

status "${BASH_SOURCE[0]} | ..."

# macos only and not signed in
if [[ $(uname -s) == "Darwin" ]]; then
  if [[ $(mas account | grep -o 'Not signed in') ]]; then
    [[ -z "${apple_store_user:-}" ]] && error "apple_store_user must be set." 1
    [[ -z "${apple_store_pw:-}" ]] && error "apple_store_pw must be set." 1

    typed_message 'CONFIG' "Login to apple store."
    # script inspired by: https://github.com/tiiiecherle/osx_install_config/blob/master/05_homebrew_and_casks/5b_homebrew_cask/6_mas_appstore.sh
    # due to issues with signin: https://github.com/mas-cli/mas/issues/164
    osascript <<EOD
      tell application "App Store"
        try
          activate
          delay 5
        end try
      end tell


      tell application "System Events"
        tell process "App Store"
          set frontmost to true
          delay 2
          ### on first run when installing the appstore asks for accepting privacy policy
          try
            click button 2 of UI element 1 of sheet 1 of window 1
            #click button "Weiter" of UI element 1 of sheet 1 of window 1
            delay 3
          end try
          ### login
          click menu item 15 of menu "Store" of menu bar item "Store" of menu bar 1
          #click menu item "Anmelden" of menu "Store" of menu bar item "Store" of menu bar 1
          delay 2
          tell application "System Events" to keystroke "${apple_store_user}"
          delay 2
          tell application "System Events" to keystroke return
          delay 2
          tell application "System Events" to keystroke "${apple_store_pw}"
          delay 2
          tell application "System Events" to keystroke return
        end tell
      end tell

      tell application "App Store"
        try
          delay 10
          quit
        end try
      end tell
EOD
  else
    typed_message 'SKIP' "Already signed in to apple store as $(mas account)."
    typed_message 'INSTALL' "Installing apple store software."
    mas install 497799835 # Xcode
    sudo xcodebuild -license accept
  fi
fi
