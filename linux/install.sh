#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

echo 'macosx/install.sh | ...'

# If we're on a Mac, let's install and setup homebrew.
if [[ $(uname -s) == "Linux" ]]; then
  echo "[INSTALL] .. installing linux specific stuff..."
  # source "${__dir}/bootstrap.sh"
fi

echo ''
exit 0