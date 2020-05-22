#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

[[ ${1:-} ]] || { echo "missing an argument. First argument must be remote. e.g. upstream" >&2; exit 1; }
[[ ${2:-} ]] || { echo "missing an argument. Second argument must be the 'master' branch. e.g. master or develop" >&2; exit 1; }
# [[ ${3:-} ]] || { echo "missing an argument. Third argument must be the remote to push updates too. For fork e.g. origin" >&2; exit 1; }
# todo: input origin and branch to sync to
git branch -vv | grep "${1}/${2}" | grep behind | awk '{print $1}' | xargs -L 1 -I {} sh -c "echo {}; git checkout {}; (git pull --rebase \"${1}\" \"${2}\" || git rebase --abort); git checkout \"${2}\"; git branch -vv"
# git branch -vv | grep "${1}/${2}" | grep behind | awk '{print $1}' | xargs -L 1 -I {} sh -c "echo {}; git checkout {}; git pull --rebase \"${1}\" \"${2}\"; git push --force-with-lease \"${1}\" {}; git checkout \"${2}\"; git branch -vv"
#gb -vv | grep origin | grep ahead | awk '{print $1}' | xargs -L 1 -I {} sh -c 'git push --force-with-lease origin {};' | git branch -vv | grep origin
