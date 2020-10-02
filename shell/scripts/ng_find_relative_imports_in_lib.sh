#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

[[ ${1:-} ]] || { echo "missing an argument. First argument must be the top level dir inside ./libs to check against. e.g. 'users'" >&2; exit 1; }

ng_lib_dir="${1}"

grep -r "from '\.\.\/\.\.\/" libs/"${ng_lib_dir}" | sed "s/.*from '\(.*\)';/\1/" | grep -v "${ng_lib_dir}\." | grep -v "${ng_lib_dir}-.*" | sort --unique
