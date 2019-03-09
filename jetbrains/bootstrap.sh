#!/usr/bin/env bash
# jetbrains/bootstrap.sh

set -o nounset
set -o errexit
set -o pipefail
DEBUG="${DEBUG:-false}"
[[ ${DEBUG} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1090
[[ "${k_custom_lib_loaded:-}" == true ]] || source "${__dir}/../shell/lib.sh"

# readonly jetbrains_login="${1:-}"

# [[ -z "${jetbrains_login}" ]] && error "first argument is empty, must be jetbrains_login" 1

if [[ $(uname -s) == "Darwin" ]]; then
  typed_message 'INSTALL' "installing jetbrains on MacOSX ..."
  jetbrains_home="${HOME}/Library/Application Support/JetBrains/Toolbox"
  settings_file="${__dir}/.settings.json"
  cp "${settings_file}.template" "${settings_file}"
  sed -i".template" "s|__HOME__|${HOME}|g" "${settings_file}"

  # sed -i' ' "s/myemail@example.com/${jetbrains_login}/g" "${settings_file}"
  java_prefs_plist="${HOME}/Library/Preferences/com.apple.java.util.prefs.plist"
  jetbrains_userid=$(/usr/libexec/PlistBuddy -c "Print :/:jetbrains/:jetprofile/:userid" "${java_prefs_plist}")

  if [[ -z "${jetbrains_userid}" ]]; then
    typed_message 'CREATE' "configs for jetbrains toolbox"
    cp "${settings_file}" "${jetbrains_home}/.settings.json"

    # Login to jetbrains
    # /usr/libexec/PlistBuddy -c "Set :/:jetbrains/:jetprofile/:userid myuser" "${java_prefs_plist}"
    open -a "JetBrains Toolbox"
    read -p "login to jetbrains toolbox and press [enter] to continue"
    [[ -z "${jetbrains_userid}" ]] && error 'failed to loging to jetbrains toolbox' 1
  else
    open -a "JetBrains Toolbox"
    typed_message 'SKIP' 'already logged into jetbrains toolbox'
  fi

  # check scripts
  jetbrains_scripts="${HOME}/data/jetbrains"
  ls "${jetbrains_scripts}" | xargs -I % sh -c "ln -s ${jetbrains_scripts}/% /usr/local/bin/% || true"
  [[ $(command -v idea) ]] || read -rp 'IntelliJ (IDEA) app not found. install a version through jetbrains toolbox. Press [enter] to continue'
  # check for apps, prompt install, rerun link
fi
