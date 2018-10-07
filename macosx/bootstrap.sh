#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

declare data_dir="${HOME}/data"
[[ -d "${data_dir}" ]] && echo "${data_dir} exists. skipping..." || mkdir "${data_dir}"
