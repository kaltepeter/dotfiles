#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

usage() {
    cat <<END
login_to_foundry.sh targetEnv

Login to foundry.
targetEnv: target targetEnv e.g. devb or devg
    -h: show this help message
END
}

error () {
    echo "Error: $1"
    exit "$2"
} >&2

while getopts ":h" opt; do
    case $opt in
        h)
            usage
            exit 0
            ;;
        :)
            error "Option -${OPTARG} is missing an argument" 2
            ;;
        \?)
            error "unkown option: -${OPTARG}" 3
            ;;
    esac
done

shift $(( OPTIND -1 ))
[[ -z "${1:-}" ]] && error 'targetEnv required. use devg or devb, prodg or prodb' 1
declare region="${2:-us2}"

declare targetEnv="${1}"
username="$(whoami)"

if [[ "${targetEnv}" =~ "prod" ]]; then
  username="${username}-a"
fi

cf api "api.sys.${region}.${targetEnv}.foundry.mrll.com"
cf login -u "${username}" -o "${region}-datasiteone" -s "${targetEnv}"
