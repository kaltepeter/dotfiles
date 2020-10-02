#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

[[ ${1:-} ]] || { echo "missing an argument. First argument must be a jira or github issues. e.g. 'MFE-162'" >&2; exit 1; }
[[ ${2:-} ]] || { echo "missing an argument. Second argument must be the gitish path. e.g. 'mymanda/develop'" >&2; exit 1; }
[[ ${3:-} ]] || { echo "missing an argument. Third argument must be the path to copy code. e.g. 'libs/users'" >&2; exit 1; }

jira="${1}"
remote_branch="${2}"
git_code_path="${3}"

echo "git read-tree --prefix=\"${git_code_path}\" -u \"${remote_branch}\":\"${git_code_path}\""
git read-tree --prefix="${git_code_path}" -u "${remote_branch}":"${git_code_path}"

git commit -m "chore(${git_code_path/libs\//}): ${jira}: copy code"
