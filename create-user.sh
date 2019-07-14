#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(k_custom_lib_loaded) == true ]] || source "${__dir}/../shell/lib.sh"

usage() {
    cat <<END
usage: [DEBUG=true] create-user.sh <username>

Create user to run bootstrap as.
Configures:

    username: the username to create

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

shift $(( OPTIND -1 ))

[[ ${1:-} ]] || error "username is empty" 1

status "${BASH_SOURCE[0]} | ..."

declare username=${1}

if id "${username}" >/dev/null; then
  typed_message 'SKIP' "user: ${username} exists."
else
  typed_message 'CREATE' "creating user: ${username}"
  sudo adduser "${username}"
  sudo adduser "${username}" sudo
  echo "verify new user"
  su - "${username}"
  sudo su
  exit
fi

echo ''
exit 0
