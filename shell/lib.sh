#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

error () {
    echo "Error: $1"
    usage
    exit "${2}"
} >&2

export declare k_custom_lib_loaded=true
