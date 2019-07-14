#!/usr/bin/env bash
# bootstrap.sh

# modified from these:
# https://github.com/holman/dotfiles/blob/master/script/install
# https://github.com/mathiasbynens/dotfiles/blob/master/bootstrap.sh

set -o nounset
set -o errexit
set -o pipefail
DEBUG="${DEBUG:-false}"
[[ ${DEBUG} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log_file="${__dir}/bootstrap.log"

# shellcheck disable=SC1090
[[ "${k_custom_lib_loaded:-}" == true ]] || source "${__dir}/shell/lib.sh"

date_header

usage() {
    cat <<END
usage: [DEBUG=true] bootstrap.sh

Setup machine with my defaults. Env vars come from .env
Configures:

    email:  primary email address for the machine.
            Used for: ssh key comment, associate to github.com

    hostname: hostname for machine

    machineuser:  username for the machine to setup.

    -h: show this help message
END
}

declare email
declare hostname

if [[ -f "${__dir}/.env" ]]; then
  # set -o allexport
  # shellcheck source=/dev/null
  source "${__dir}/.env"
  # set +o allexport
else
  echo ".env file doesn't exist. creating from .example file."
  cp "${__dir}/.env.example" "${__dir}/.env"
  error "IMPORTANT: edit values and re-run bootstrap." 1
fi

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

shift $(( OPTIND -1 ))

[[ -z "${email:-}" ]] && error "email is empty" 1

echo ''

if [[ "${DEBUG}" == true ]]; then
  declare -p
fi

status "${BASH_SOURCE[0]} | ..."

echo "setting up machine $(hostname) as ${hostname} for ${email}..."

declare data_dir="${HOME}/data"
if [[ -d "${data_dir}" ]]; then
  typed_message 'SKIP' "${data_dir} exists."
else
  typed_message 'CREATE' "${data_dir}...";
  mkdir "${data_dir}"
fi

echo ''

# export for child shells
export log_file
export email
export hostname
export apple_store_user
export apple_store_pw

# pre-req: MAC allow applescript to run in terminal
[[ $(command -v osascript) ]] && osascript "${__dir}/macosx/script/show_security_settings.applescript"

# find the installers and run them iteratively
find -s . -name install.sh | while read -r installer ; do sh -c "${installer}" ; done

sh -c "${__dir}/macosx/bootstrap.sh"
sh -c "${__dir}/system/bootstrap.sh"
sh -c "${__dir}/git/bootstrap.sh"
sh -c "${__dir}/jetbrains/bootstrap.sh"

typed_message 'CLEANUP' "removing env vars"

echo ''
typed_message '-----' 'All installed! check for [FAIL] to fix any issues and re-run.'

unset email
unset hostname
unset pw
unset machineuser
unset username
unset log_file
unset apple_store_user
unset apple_store_pw

exit 0
