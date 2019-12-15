#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace
[[ ${1:-} ]] || { echo "missing an argument. first argument must be branch to
compare with. e.g. upstream/master" >&2; exit 1; }
git branch --merged "${1}" | grep -v 'master\|develop' | xargs -I {} sh -c 'git branch -d {} \
&& git push origin --delete {}'
