#!/usr/bin/env bash
# google/install.sh
set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"

status "${BASH_SOURCE[0]} | ..."

if test ! "$(command -v gcloud)"; then
  typed_message 'INSTALL' "gcloud"
  curl https://sdk.cloud.google.com | bash
  # shellcheck disable=SC2093
  exec -l "$SHELL"
  gcloud init
else
  typed_message 'SKIP' "glcloud already installed. Initializing"
  typed_message 'INSTALL' "Updating gcloud components."
  gcloud components update
fi

echo ''

exit 0
