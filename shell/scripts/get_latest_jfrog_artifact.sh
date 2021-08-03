set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

usage() {
    cat <<END
get_latest_jfrog_artifact.sh scope name additional_tags

Get last created jfrog artifact by artifact name and scope.
repo: jfrog repo e.g. my-npm
scope: jfrog/npm scope to search e.g. @mrll, @my-org
name: artifact name e.g. my-app
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
[[ -z "${2:-}" ]] && error 'scope is required to be the second argument' 1
[[ -z "${3:-}" ]] && error 'name is required to be the third argument' 1
declare repo="${1}"
declare scope="${2}"
declare name="${3}"
declare additional_tags="${4:-;}"

jfrog rt search "${repo}/${scope}/*/*-*.tgz" "--props=${additional_tags}artifact.type=app;npm.name=${scope}/${name}" --sort-by=created --sort-order=desc --limit=1
