#!/usr/bin/env bash
# bootstrap.sh

# modified from these:
# https://github.com/holman/dotfiles/blob/master/script/install
# https://github.com/mathiasbynens/dotfiles/blob/master/bootstrap.sh

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

echo ''

echo 'Bootstrapping...'

declare data_dir="${HOME}/data"
[[ -d "${data_dir}" ]] && echo "[SKIP] ... ${data_dir} exists." || (echo "[CREATE] ... ${data_dir}..."; mkdir "${data_dir}")

# find the installers and run them iteratively
find . -name install.sh | while read installer ; do sh -c "${installer}" ; done

echo ''
echo '  All installed!'

exit 0