#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CI=${CI:-false}

if [[ ${CI} == false ]]; then
  # shellcheck disable=SC2317  # Don't warn about unreachable commands in this function
  end () { [[ $? = 0 ]] && return; echo "[FAILED] Script failed, check the output."; exit 1; }
  trap end EXIT 
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
  ##### replace with your own code when creating a new script #####
  say_hello
  ##### replace with your own code when creating a new script #####

  echo ''
  exit 0
fi