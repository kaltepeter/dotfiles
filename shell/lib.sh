#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

log_file="${log_file:-/dev/null}"
script_name="${script_name:-}"

end () { 
  if [[ $? == 0 ]]; then
    status "\n[END] ${script_name}"
    unset script_name
    return
  else
    echo -e "\n\033[31m[FATAL] ${script_name} failed, check the output.\033[39m"
    exit $?
  fi
}

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
  color_end=$'\033[39m'
  case "${1}" in
  SKIP)
    color_start=$'\033[93m'
    ;;
  FAIL)
    color_start=$'\033[31m'
    ;;
  CLEANUP)
    color_start=$'\033[94m'
    ;;
  CONFIG | INSTALL | UPDATE)
    color_start=$'\033[92m'
    ;;
  INSTRUCTION)
    color_start=$'\033[35m'
    ;;
  *)
    color_start=$'\033[37m'
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
error() {
  echo -e "\033[31mError: ${1}\033[39m" | tee -a "${log_file}"
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
status() {
  echo -e "\033[36m${1}\033[39m" 
} >&1

filter_usage() {
  cat <<END
usage: [DEBUG=1|2] ${0} [-h] [--type home|work] [--filter tag] 
--type home|work: specify the type of setup to run. home is default.
--filter tag: specify tags to run. 

  tags: 
    core: only bare minimum setup. If combined with work or home, it will run only the core items for those tags. 
    directory_name: run setup for a specific directory only. 

DEBUG=1 prints each command with a + in front before executing it. Vars are evaluated in the print.
DEBUG=2 prints each line of the script until a command is executed. Also prints the same output as DEBUG=1 after each script line is printed.

-h: show help
END
}

filter_opts() {
  echo ${1}
  echo ${2}
  local -n local_filters=$1
  local -n local_type=$2

  local_filters=()
  local_type="home"

  echo ${local_filters}
  echo ${local_type}

  while getopts ":h-:" opt; do
      case "${opt}" in
          -)
              case "${OPTARG}" in
                  type)
                    local_type="${!OPTIND}"
                    OPTIND=$(( $OPTIND + 1 ))
                    ;;
                  filter)
                    local_filters+=("${!OPTIND}")
                    OPTIND=$(( $OPTIND + 1 ))
                    ;;
                  help)
                    filter_usage
                    exit 0
                    ;;
                  *)
                    echo "Invalid option: --${OPTARG}" >&2
                    filter_usage
                    exit 1
                    ;;
              esac
              ;;
          h)
              filter_usage
              exit 0
              ;;
          \?)
              echo "Invalid option: -$OPTARG" >&2
              filter_usage
              exit 1
              ;;
      esac
  done
  shift $((OPTIND -1))

  filter_str=""

  if [[ ${#local_filters[@]} > 0 ]]; then
    filter_str=" filters=(${local_filters[@]})"
  fi

  typed_message 'RUN' "Machine type: ${local_type}${filter_str}"
}

# TODO: rename to script_header
date_header() {
  echo -e "\n"
  date
  status "[RUN] ${script_name}"
  echo
}

get_dirs_for_filters() {
  [[ ${1:-} ]] || { echo "The first argument to apply_filters must be a directory"; exit 1; }
  local -n dirs=$2
  local root_dir="${1}"
  for item in "${filters[@]}"; do
    # dirs+=$(find "${root_dir}" -type d -name "${item}" -maxdepth 1)
    readarray -t tmp < <(find "${root_dir}" -type d -name "${item}" -maxdepth 1)
    dirs+=("${tmp[@]}")
  done
}

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
typed_message() {
  printf '%*s %s\n' 28 "$(get_colorized_prefix $1)" "${2}" | tee -a "${log_file}"
}

#######################################
# update and cleanup brew
# Arguments:
#   None
# Returns:
#   None
#######################################
update_brew() {
  # https://medium.com/@waxzce/keeping-macos-clean-this-is-my-osx-brew-update-cli-command-6c8f12dc1731
  brew update
  brew upgrade
  # (brew cask upgrade >>"${log_file}" 2>&1) || true
  brew cleanup -s
  # brew cask cleanup
  # brew doctor always errors, not great
  typed_message 'VERIFY' "Check 'brew doctor' output in log for issues."
  (brew doctor >>"${log_file}" 2>&1) || true
  brew missing | tee -a "${log_file}"
  # echo "" | tee -a "${log_file}"
  # brew cask doctor 1>>"${log_file}"
  echo "" | tee -a "${log_file}"
}

k_custom_lib_loaded() {
  echo true
}

export -f end
export -f error
export -f usage
export -f status
export -f get_colorized_prefix
export -f date_header
export -f typed_message
export -f update_brew
export -f k_custom_lib_loaded
export -f filter_opts
export -f get_dirs_for_filters