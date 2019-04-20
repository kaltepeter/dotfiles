#!/usr/bin/env bash
# macosx/install
set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ "${k_custom_lib_loaded:-}" == true ]] || source "${__dir}/../shell/lib.sh"
log_file="${log_file:-/dev/null}"

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

  # clear custom catalog, use default apple catalog
  # softwareupdate --clear-catalog
  # udpate recommended updates before continuing
  sudo softwareupdate --verbose --install --recommended --restart | tee -a "${log_file}"

   # Use Dark theme
  osascript <<EOD
    tell application "System Events"
      tell appearance preferences
        set dark mode to true
        set highlight color to purple
      end tell
    end tell
EOD

killall "Brave Browser" &> /dev/null || true
sleep 1
open -a "Brave Browser" --args --make-default-browser | tee -a "${log_file}"

# osascript <<EOD
# do shell script "open -a \"Brave Browser\" --args --make-default-browser"
# activate
# delay 1
# end
# EOD

# lines below would automate but require access approved in script accessibility
# a tool like tccutil would work

#   osascript <<EOD
#     do shell script "open -a \"Brave Browser\" --args --make-default-browser"
#       activate
#       delay 1
#     end

#     tell application "System Events" to tell application process "CoreServicesUIAgent"
#       tell button [0] in window 1
#         perform action "AXPress"
#       end tell
#     end tell
# EOD

  # Set sidebar icon size to medium
  defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

  # Automatic show scrollbars
  defaults write NSGlobalDomain AppleShowScrollBars -string "Automatic"
  # Possible values: `WhenScrolling`, `Automatic` and `Always`

  # Reveal IP address, hostname, OS version, etc. when clicking the clock
  # in the login window
  # need to validate
  sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

  ###############################################################################
  # Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
  ###############################################################################

  # Trackpad: enable tap to click for this user and for the login screen
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  # defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  # lookup with three finger tap
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 2
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerTapGesture -int 2

  # Trackpad: map bottom right corner to right-click
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -int 1
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -int 1

  # Disable “natural” (Lion-style) scrolling
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

  # Set language and text formats
  # Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
  # `Inches`, `en_GB` with `en_US`, and `true` with `false`.
  defaults write NSGlobalDomain AppleLanguages -array "en" "nl"
  defaults write NSGlobalDomain AppleLocale -string "en_US"
  defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"
  defaults write NSGlobalDomain AppleMetricUnits -bool false

  # Set the timezone; see `sudo systemsetup -listtimezones` for other values
  sudo systemsetup -settimezone "America/Chicago" > /dev/null

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
# Address Book, Dashboard, iCal, TextEdit, and Disk Utility                   #
###############################################################################

# Enable Dashboard dev mode (allows keeping widgets on the desktop)
# defaults write com.apple.dashboard devmode -bool true

# # Use plain text mode for new TextEdit documents
# defaults write com.apple.TextEdit RichText -int 0
# # Open and save files as UTF-8 in TextEdit
# defaults write com.apple.TextEdit PlainTextEncoding -int 4
# defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4s

# # Auto-play videos when opened with QuickTime Player
# defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true

###############################################################################
# Mac App Store                                                               #
###############################################################################

# Enable the WebKit Developer Tools in the Mac App Store
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Automatically download apps purchased on other Macs
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

# Turn on app auto-update
defaults write com.apple.commerce AutoUpdate -bool true

# Allow the App Store to reboot machine on macOS updates
defaults write com.apple.commerce AutoUpdateRestartRequired -bool true

###############################################################################
# Photos                                                                      #
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

# Show the full URL in the address bar (note: this still hides the scheme)
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Set Safari’s home page to `about:blank` for faster loading
# defaults write com.apple.Safari HomePage -string "about:blank"

# Prevent Safari from opening ‘safe’ files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Hide Safari’s bookmarks bar by default
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Hide Safari’s sidebar in Top Sites
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

# Enable Safari’s debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Enable debug menu
defaults write com.apple.Safari IncludeDevelopMenu -bool true

# Make Safari’s search banners default to Contains instead of Starts With
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# Remove useless icons from Safari’s bookmarks bar
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

# Enable webkit developer extras
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true


  ###############################################################################
  # Kill affected applications                                                  #
  ###############################################################################

    # "Calendar" \
    # "Contacts" \
    # "Google Chrome Canary" \
    # "Google Chrome" \
    # "Mail" \
    # "Messages" \
    # "Opera" \
    # "SizeUp" \
    # "Spectacle" \
    # "Transmission" \
    # "Tweetbot" \
    # "Twitter" \
    for app in "Activity Monitor" \
    "Brave Browser" \
    "cfprefsd" \
    "Dock" \
    "Finder" \
    "Photos" \
    "Safari" \
    "SystemUIServer" \
    "Terminal" \
    "iCal"; do
      killall "${app}" &> /dev/null || true
    done
    echo "Done. Note that some of these changes require a logout/restart to take effect."
  fi

  echo ''
  exit 0
