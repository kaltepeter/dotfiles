#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

input="${1:-/dev/stdin}"

# Takes stdin from a git fetch: `git fetch --all | sync_auto_deleted_branches.sh`
# If only origin: skip
# If has upstream: delete origin branches (fork)

declare hasUpstream="FALSE"

if git remote | grep -q upstream; then
  hasUpstream="TRUE"
  echo "Remote has upstream"
fi

while read -r line; do
  if echo "$line" | grep -q 'deleted'; then
    # parse line for remote/branch_name to array
    IFS=" " read -r -a branch_out <<<"$(echo "$line" | awk -F " " '{print $NF}' | awk '{sub(/\//," ")}1')"
    branch_remote=${branch_out[0]}
    branch_name=${branch_out[1]}
    # Only process if on origin and hasUpstream
    if [[ "${branch_remote}" == 'origin' && "${hasUpstream}" == "TRUE" ]]; then
      branch_status=$(git branch -vv | grep "${branch_name}")
      # SKIP branches that are ahead of tracking branch
      if echo "${branch_status}" | grep -q 'ahead'; then
        echo "Brach is ahead of tracking branch. SKIPPING"
      else
        # safe to delete, not ahead, on fork
        read -r -p "Delete local branch: ${branch_name}(y/n)" should_delete </dev/tty
        if [[ "${should_delete,,}" == "y" ]]; then
          echo "Should delete: ${branch_name}"
        fi
      fi
    fi
  fi
done <"$input"

echo ""
