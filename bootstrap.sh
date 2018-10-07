#!/usr/bin/env bash
# bootstrap.sh

# modified from these:
# https://github.com/holman/dotfiles/blob/master/script/install
# https://github.com/mathiasbynens/dotfiles/blob/master/bootstrap.sh

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

error () {
    echo "Error: $1"
    usage
    exit $2
} >&2

usage() {
    cat <<END
usage: bootstrap.sh <email>

Setup MacOSX with my defaults.
Configures:
    
    email: primary email address for the machine. Used for: ssh key comment, associate to github.com
    
    -h: show this help message
END
}

[[ ${1:-} ]] || error "email is empty" 1


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
declare email="${1}"

echo ''

echo 'bootstrap.sh | Bootstrapping...'
echo "setting up $(hostname) for ${email}..."

declare data_dir="${HOME}/data"
[[ -d "${data_dir}" ]] && echo "[SKIP] ... ${data_dir} exists." || (echo "[CREATE] ... ${data_dir}..."; mkdir "${data_dir}")

echo ''

# export for child shells
export email

# find the installers and run them iteratively
find . -name install.sh | while read installer ; do sh -c "${installer}" ; done

echo ''
echo '  All installed!'

exit 0