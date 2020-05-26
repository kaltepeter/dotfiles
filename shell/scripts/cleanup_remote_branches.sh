#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

[[ ${1:-} ]] || { echo "missing an argument. first argument must be remote to clean. e.g. jaas" >&2; exit 1; }

git branch -r | grep "${1}" | awk '!/master/' && '!/develop/' | awk -F'[/]' '{print $1, $2}' | xargs -I {} sh -c "git push --delete {}"
