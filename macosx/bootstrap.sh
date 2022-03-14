#!/usr/bin/env bash
#
# macosx/bootstrap.sh

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"

status "${BASH_SOURCE[0]} | ..."

# macos only and not signed in
if [[ $(uname -s) == "Darwin" ]]; then
  if [[ $(mas account | grep -o 'Not signed in') ]]; then
    [[ -z "${apple_store_user:-}" ]] && error "apple_store_user must be set." 1
    [[ -z "${apple_store_pw:-}" ]] && error "apple_store_pw must be set." 1

    typed_message 'CONFIG' "Login to apple store."
    osascript "${__dir}/script/signin_to_appstore.applescript" "${apple_store_user}" "${apple_store_pw}"
  else
    typed_message 'SKIP' "Already signed in to apple store as $(mas account)."
    typed_message 'INSTALL' "Installing apple store software."
    # mas install 497799835 # Xcode
    # sudo xcodebuild -license accept
  fi
fi
