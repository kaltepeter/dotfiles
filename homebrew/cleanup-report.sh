#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" 

end () { [[ $? = 0 ]] && return; echo "[FAILED] Script failed, check the output."; exit 1; }
trap end EXIT

rm "${__dir}/packages-to-clean.log" || true

echo "Casks that can be removed"
brew list --cask | while read -r formula; do
    if ! grep --quiet "${formula}" "${__dir}/core-casks.txt"; then
        echo "${formula}" | tee -a "${__dir}/packages-to-clean.log"
    fi
done

echo "Formulas that can be removed"
brew list --formula | while read -r formula; do
  if ! grep --quiet "${formula}" "${__dir}/core.txt"; then
    echo "${formula}" | tee -a "${__dir}/packages-to-clean.log"
  fi
done

exit 0