#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)/.."
CI=${CI:-false}

# shellcheck disable=SC1091
[[ $(command -v k_custom_lib_loaded) ]] || source "${__root}/shell/lib.sh"

if [[ ${CI} == false ]]; then
  trap inner_end EXIT 
fi

##### replace with your own code when creating a new script #####
# shellcheck disable=SC2120
say_hello() {
    name=${1:-}
    if [[ -z ${name} ]]; then
      read -r -p "What is your name? " name
    fi
    echo "Hello, ${name}!"
}
##### replace with your own code when creating a new script #####

if [[ ${CI} == false ]]; then
  inner_header
  ##### replace with your own code when creating a new script #####
  say_hello
  ##### replace with your own code when creating a new script #####

  echo ''
  exit 0
fi