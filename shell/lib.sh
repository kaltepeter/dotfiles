#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

log_file="${log_file:-/dev/null}"

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
  echo -e "\e[31mError: ${1}\e[39m" | tee -a "${log_file}"
  echo '' | tee -a "${log_file}"
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
  echo -e "\e[36m'${1}'\e[39m" | tee -a "${log_file}"
} >&1

date_header () {
  echo '' | tee -a "${log_file}"
  echo $(date) | tee -a "${log_file}"
  echo '' | tee -a "${log_file}"
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
   printf '%*s %s\n' 26 "$(get_colorized_prefix $1)" "${2}" | tee -a "${log_file}"
}

#######################################
# update and cleanup brew
# Arguments:
#   None
# Returns:
#   None
#######################################
update_brew () {
  # https://medium.com/@waxzce/keeping-macos-clean-this-is-my-osx-brew-update-cli-command-6c8f12dc1731
  brew update
  brew upgrade
  brew cask upgrade
  brew cleanup -s
  # brew cask cleanup
  # brew doctor always errors, not great
  typed_message 'VERIFY' "Check 'brew doctor' output in log for issues."
  (brew doctor >>"${log_file}" 2>&1) || true
  brew missing | tee -a "${log_file}"
  echo "" | tee -a "${log_file}"
  brew cask doctor 1>> "${log_file}"
  echo "" | tee -a "${log_file}"
}

k_custom_lib_loaded() {
  echo true
}

export -f error
export -f usage
export -f status
export -f get_colorized_prefix
export -f date_header
export -f typed_message
export -f update_brew
export -f k_custom_lib_loaded
