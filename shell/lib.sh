#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

export -f error () {
    echo "Error: $1"
    usage
    exit "${2}"
} >&2

export -f usage() {
	cat <<END
Overwrite usage function in shell script to provide help.
Make sure you put the function after the library load.
END
	exit 1
}

export declare k_custom_lib_loaded=true
