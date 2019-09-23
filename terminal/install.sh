#!/usr/bin/env bash
# terminal/install

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"
status "${BASH_SOURCE[0]} | ..."

typed_message 'CONFIG' "terminal themes"

typed_message 'CREATE' "modified material themes"
cp -f "${__dir}/../materialshell/shell-color-themes/macOS/terminal/"*.terminal "${__dir}/modified_themes/"

declare -a theme_files=($(ls "${__dir}/modified_themes/"*.terminal))
terminal_defaults="${HOME}/Library/Preferences/com.apple.Terminal.plist"

for theme in "${theme_files[@]}"; do
  name=$(plutil -extract "name" xml1 -o - ${theme} | plutil -p -)
  typed_message 'CREATE' "${theme} ${name}"
  font_data='YnBsaXN0MDDUAQIDBAUGGBlYJHZlcnNpb25YJG9iamVjdHNZJGFyY2hpdmVyVCR0b3ASAAGGoKQHCBESVSRudWxs1AkKCwwNDg8QVk5TU2l6ZVhOU2ZGbGFnc1ZOU05hbWVWJGNsYXNzI0AqAAAAAAAAEBCAAoADXxAcSGFja05lcmRGb250Q29tcGxldGUtUmVndWxhctITFBUWWiRjbGFzc25hbWVYJGNsYXNzZXNWTlNGb250ohUXWE5TT2JqZWN0XxAPTlNLZXllZEFyY2hpdmVy0RobVHJvb3SAAQgRGiMtMjc8QktSW2JpcnR2eJecp7C3usPV2N0AAAAAAAABAQAAAAAAAAAcAAAAAAAAAAAAAAAAAAAA3w=='
  plutil -replace "Font" -data "${font_data}" "${theme}"
  plutil -replace "Window Settings"."${name//\"}" -xml """$(cat "${theme}")""" "${terminal_defaults}"
done

typed_message 'CONFIG' "set default theme"
# plutil -replace "Startup Window Settings" -string "Material Shell - Dark" -o "${terminal_defaults}" "${terminal_defaults}"
defaults write com.apple.Terminal "Startup Window Settings" "Material Shell - Dark"
defaults write com.apple.Terminal "Default Window Settings" "Material Shell - Dark"

echo ''
exit 0
