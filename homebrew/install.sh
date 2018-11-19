#!/bin/sh
# homebrew/install

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"

echo "${__file} | ..."

# from: https://github.com/holman/dotfiles/blob/master/homebrew/install.sh
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Check for Homebrew
if test ! "$(command -v brew)"; then
	echo "[INSTALL] ... Homebrew"

	# Install the correct homebrew for each OS type
	if test "$(uname)" = "Darwin"; then
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	# elif test [[ substr "$(uname -s)" 1 5 = "Linux" ]]; then
	# 	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
  else
    echo "[SKIP] ... Brew. Not a Mac."
	fi
else
	echo "[SKIP] ... brew already installed."
	brew --version
fi

echo ''

sh -c "${__dir}/brew.sh"

exit 0
