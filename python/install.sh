#!/usr/bin/env bash
#
# python/install
set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"

status "${BASH_SOURCE[0]} | ..."

declare python_version=$(pyenv install -l | ggrep -E '^[ 3]+\.[0-9\.]+$' | sed -n '$p')
if pyenv versions | grep -q "${python_version}"; then
  typed_message 'SKIP' "python ${python_version} exists."
else
  typed_message 'INSTALL' "python ${python_version}"
  pyenv install ${python_version}
fi

pyenv version

if which pip3; then
  typed_message 'INSTALL' "installing global pip packages ..."
  # pip3 install termcolor
  # pip3 install pylint
  # pip3 install pep8
  # source "${__dir}/bootstrap.sh"
fi

# if which pyenv-virtualenv-init >/dev/null; then eval "$(pyenv virtualenv-init -)"; fi

echo ''
exit 0
