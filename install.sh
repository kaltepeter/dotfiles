#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

declare data_dir="${HOME}/data"
if [[ -d "${data_dir}" ]]; then
  echo "SKIP ${data_dir} exists."
else
  echo "CREATE ${data_dir}..."
  mkdir "${data_dir}"
fi

git clone git@github.com:kaltepeter/dotfiles.git "${HOME}/data/"

cd "${HOME}/data"

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log_file="${__dir}/install.log"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/shell/lib.sh"

usage() {
  cat <<END
usage: [DEBUG=true] install.sh

Automatically write to .env file and run bootstrap.

    -h: show this help message
END
}

while getopts "h" opt; do
  case $opt in
  h)
    usage
    exit 0
    ;;
  \?)
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

if [[ ! -f "${__dir}/.env" ]]; then
  typed_message 'CONFIG' "First run. ${__dir}/.env doesn't exist."
fi

input="${__dir}/.env.example"
typed_message 'CONFIG' "writing inputs to ${__dir}/.env file"
while IFS= read -r line; do
  [[ ${line} =~ ^#.*s ]] && continue
  # shellcheck disable=SC1001
  IFS=\= read -r key value <<<"${line}"
  # http://compgroups.net/comp.unix.shell/fixing-stdin-inside-a-redirected-loop/400460
  grep -q "${key}=" "${__dir}/.env" || (
    read -r -p "${key}(${value}): " val </dev/tty
    echo "${key}=${val}" >>"${__dir}/.env"
  )
done <"$input"
# error "IMPORTANT: edit values and re-run bootstrap." 1

set -o allexport
typed_message 'CONFIG' "setting vars from ${__dir}/.env"
# shellcheck source=/dev/null
source "${__dir}/.env"
set +o allexport

sh "${__dir}/bootstrap.sh"

echo ''

echo ''
exit 0
