#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

[[ ${1:-} ]] || { echo "missing an argument. First argument must be the top level dir inside ./libs to check against. e.g. 'users'" >&2; exit 1; }
[[ ${2:-} ]] || { echo "missing an argument. Second argument must be the npm scope of lib import e.g. @mrll" >&2; exit 1; }

ng_lib_dir="${1}"
lib_scope="${2}"

# recurse through a top level dir inside ./libs, find libs at any depth due to 'src' being immediate parent
# get the immediate parent of 'src'
# look for any imports of it's own lib
find "./libs/${ng_lib_dir}" -type d -name "src" | sed 's/.*\/\(.*\)\/src/\1/' | xargs -I "libname" grep -r "${lib_scope}/${ng_lib_dir}/libname" "./libs/${ng_lib_dir}/libname"
