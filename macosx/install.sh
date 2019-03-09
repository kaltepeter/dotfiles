#!/usr/bin/env bash
# macosx/install
set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ "${k_custom_lib_loaded:-}" == true ]] || source "${__dir}/../shell/lib.sh"

status "${BASH_SOURCE[0]} | ..."

# If we're on a Mac, let's install and setup homebrew.
if [[ $(uname -s) == "Darwin" ]]; then
  typed_message 'INSTALL' "installing macosx specific stuff..."
  # source "${__dir}/bootstrap.sh"
  # Close any open System Preferences panes, to prevent them from overriding
  # settings we’re about to change
  osascript -e 'tell application "System Preferences" to quit'

  # Ask for the administrator password upfront
  sudo -v

  # Keep-alive: update existing `sudo` time stamp until `.macos` has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

  ###############################################################################
  # Activity Monitor                                                            #
  ###############################################################################

  # Show the main window when launching Activity Monitor
  defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

  # # Visualize CPU usage in the Activity Monitor Dock icon
  defaults write com.apple.ActivityMonitor IconType -int 5

  # # Show all processes in Activity Monitor
  defaults write com.apple.ActivityMonitor ShowCategory -int 0

  # # Sort Activity Monitor results by CPU usage
  defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
  defaults write com.apple.ActivityMonitor SortDirection -int 0

  # Sort columns in each tab
defaults write com.apple.ActivityMonitor UserColumnSortPerTab -dict \
    '0' '{ direction = 0; sort = CPUUsage; }' \
    '1' '{ direction = 0; sort = anonymousMemory; }' \
    '2' '{ direction = 0; sort = PowerScore; }' \
    '3' '{ direction = 0; sort = bytesWritten; }' \
    '4' '{ direction = 0; sort = txBytes; }'

  ###############################################################################
  # Kill affected applications                                                  #
  ###############################################################################

    # "Address Book" \
    # "Calendar" \
    # "cfprefsd" \
    # "Contacts" \
    # "Dock" \
    # "Finder" \
    # "Google Chrome Canary" \
    # "Google Chrome" \
    # "Mail" \
    # "Messages" \
    # "Opera" \
    # "Photos" \
    # "Safari" \
    # "SizeUp" \
    # "Spectacle" \
    # "SystemUIServer" \
    # "Terminal" \
    # "Transmission" \
    # "Tweetbot" \
    # "Twitter" \
  for app in "Activity Monitor" \
    "iCal"; do
    killall "${app}" &> /dev/null
  done
  echo "Done. Note that some of these changes require a logout/restart to take effect."
fi

echo ''
exit 0
