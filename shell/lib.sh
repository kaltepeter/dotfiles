#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

usage() {
	cat <<END
Overwrite usage function in shell script to provide help.
Make sure you put the function after the library load.
END
	exit 1
}

#######################################
# Get colorized tagged text i.e. [SKIP]
# FAIL is non fatal errors, for fatal
# use error function
# Arguments:
#   1: tag type
# Returns:
#   padded tagged message type
#            [SKIP] ...
#           [ERROR] ...
#######################################
get_colorized_prefix() {
  declare color_start
  color_end=$'\e[39m'
  case "${1}" in
    SKIP)
      color_start=$'\e[93m'
      ;;
    FAIL)
      color_start=$'\e[31m'
      ;;
    CLEANUP)
      color_start=$'\e[94m'
      ;;
    CONFIG|INSTALL)
      color_start=$'\e[92m'
      ;;
    *)
      color_start=$'\e[37m'
      ;;
  esac
  echo "${color_start}[${1}]${color_end} ..."
}

#######################################
# Print error message and useage than
# exit with error code
# Arguments:
#   1: message to print
#   2: error exit code
# Returns:
#   None
#######################################
error () {
  echo -e "\e[31mError: ${1}\e[39m"
  echo ''
  usage
  echo ''
  exit "${2}"
} >&2


#######################################
# Print status message
# Arguments:
#   1: message to print
# Returns:
#   None
#######################################
status () {
  echo -e "\e[36m${1}\e[39m"
} >&1

#######################################
# get tagged message with colors
# Arguments:
#   1: tagged type see
#     get_colorized_prefix for examples
#   2: message
# Returns:
#   Formatted message
#            [SKIP] ... My message
#######################################
typed_message () {
   printf '%*s %s\n' 26 "$(get_colorized_prefix $1)" "${2}"
}

export -f error
export -f usage
export -f status
export -f get_colorized_prefix
export -f typed_message
export declare k_custom_lib_loaded=true
