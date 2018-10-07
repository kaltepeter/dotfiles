#!/usr/bin/env bash
# macosx/install

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo 'macosx/install.sh | ...'

# If we're on a Mac, let's install and setup homebrew.
if [ "$(uname -s)" == "Darwin" ]
then
  info "[INSTALL] .. installing macosx specific stuff..."
  # source "${__dir}/bootstrap.sh"
fi