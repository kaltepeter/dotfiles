#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

usage() {
    cat <<END
get_latest_jfrog_artifact.sh repo (scope/name|name) additional_tags

Get last created jfrog artifact by artifact name and scope.
repo: jfrog repo e.g. my-npm
name: artifact scope/name or name e.g. my-app or @my-org/my-app
additionaltags: ; separated jfrog props to add to the search

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
[[ -z "${1:-}" ]] && error 'repo is required to be the first argument' 1
[[ -z "${2:-}" ]] && error '(scope/name | name) is required to be the second argument' 1

declare repo="${1}"
declare name="${2}"
declare -i limit=${3:-1}
declare additional_tags="${4:-;}"

if [[ "${DEBUG:-}" == true ]]; then
    # set -o xtrace
    echo "repo: ${repo}"
    echo "name: ${name}"
    echo "limit: ${limit}"
    echo "additional_tags: ${additional_tags}"
    export JFROG_CLI_LOG_LEVEL=DEBUG
fi

jfrog rt search "${repo}/${name}/*" "--props=${additional_tags}" --sort-by=created --sort-order=desc --limit="${limit}"
