#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

_mock_git() {
    echo "git $*"
}

_common_setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/bats-file/load'
    bats_require_minimum_version 1.5.0
    export CI=true
    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    # shellcheck disable=SC2034
    PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    # PATH="$PROJECT_ROOT/src:$PATH"
    # shellcheck disable=SC2034
    install_dir="$(temp_make)"

    export BATSLIB_TEMP_PRESERVE=0
    export BATSLIB_TEMP_PRESERVE_ON_FAILURE=0
    export BATSLIB_FILE_PATH_REM=""
    export BATSLIB_FILE_PATH_ADD='<temp>'
}

_common_teardown() {
    # temp_del "${install_dir}" # won't work with git sub directory
    rm -rf "${install_dir}"
}