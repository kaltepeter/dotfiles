#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

[[ ${1:-} ]] || { echo "missing an argument. First argument must be the top level dir inside ./libs to check against. e.g. 'users'" >&2; exit 1; }
[[ ${2:-} ]] || { echo "missing an argument. Second argument must be the npm scope of lib import e.g. @mrll" >&2; exit 1; }

ng_lib_dir="${1}"
lib_scope="${2}"

grep -r "${lib_scope}/" ./libs/"${ng_lib_dir}" | grep -v "${lib_scope}/${ng_lib_dir}/" | sed "s/.*\(${lib_scope}\/.*\)';/\1/" | sort --unique
