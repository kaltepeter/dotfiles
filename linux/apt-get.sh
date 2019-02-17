#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

echo "[CONFIG] ... check for latest updates..."
sudo apt-get update
sudo apt-get upgrade

if ! command -v zsh; then
	sudo apt-get install zsh
fi

# TODO: purge and clean apt-get

echo ''
exit 0
