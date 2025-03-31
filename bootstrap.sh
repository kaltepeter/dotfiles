#!/usr/bin/env bash
# bootstrap.sh
set -o errexit
set -o pipefail
set -o nounset
DEBUG=${DEBUG:-0}
((DEBUG >= 1)) && set -o xtrace;
((DEBUG >= 2)) && set -o verbose;
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CI=${CI:-false}
script_name="$(basename "${BASH_SOURCE[0]}")"
log_file="${__dir}/logs/${script_name/%.*/.log}"
brew_caveats_log="${__dir}/logs/brew_caveats.log"

# global because bash 3 doesn't support local -n and mac defaults to bash 3 
declare -a filters=()
declare machine_type='home'
export script_name

if [[ -z "${BATS_TEST_FILENAME:-}" ]]; then
  exec 3>&2 > >(tee "${log_file}") 2>&1
fi

# shellcheck disable=SC1091
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/shell/lib.sh"

if [[ ${CI} == false ]]; then
  trap end EXIT 
fi

usage() {
  cat <<END
usage: [DEBUG=1|2] ${0} [-h|--help] [--type home|work] [--filter package] [--filter other_package] 
  --type home|work: specify the type of setup to run. home is default.
  --filter package: specify packages to run. Invalid packages will be ignored. Pass one or many filters.

  packages: 
    essential: only bare minimum setup.

    all available packages:
    $(find "${__dir}/packages" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;) 

DEBUG=1 prints each command with a + in front before executing it. Vars are evaluated in the print.
DEBUG=2 prints each line of the script until a command is executed. Also prints the same output as DEBUG=1 after each script line is printed.

-h|--help: show help
END
}

filter_opts() {
  while getopts ":h-:" opt; do
      case "${opt}" in
          -)
              case "${OPTARG}" in
                  type)
                    machine_type="${!OPTIND}"
                    OPTIND=$(( OPTIND + 1 ))
                    ;;
                  filter)
                    if find "${__dir}/packages" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | grep -q "^${!OPTIND}$"; then
                      filters+=("${!OPTIND}")
                    else
                      echo "[WARN] Removing invalid filter: ${!OPTIND}"
                    fi
                    OPTIND=$(( OPTIND + 1 ))
                    ;;
                  help)
                    usage
                    exit 0
                    ;;
                  *)
                    echo "Invalid option: --${OPTARG}" >&2
                    usage
                    return 1
                    ;;
              esac
              ;;
          h)
              usage
              exit 0
              ;;
          \?)
              echo "Invalid option: -$OPTARG" >&2
              usage
              return 1
              ;;
      esac
  done
  # filter_str=""

  # if [[ ${#local_filters[@]} > 0 ]]; then
  #   filter_str=" filters=(${local_filters[@]})"
  # fi

  # typed_message 'RUN' "Machine type: ${machine_type} ${filters[*]}"
}

run_essential() {
  typed_message 'RUN' "filter=essential"
  bash "${__dir}/packages/install.sh"
  find "${__dir}/packages/essential" -type file -name "config.sh" -exec bash {} \;
  check_1password
}

check_1password() {
  # Replace the manual prompt with an automatic check
  if ! op account get &>/dev/null; then
    typed_message 'CONFIG' "1Password CLI needs to be enabled. Visit https://developer.1password.com/docs/cli/app-integration/ for details."
    read -r -p "Once complete type 'cont' to continue." input
    echo -e "\n"
    if [[ "$input" != "cont" ]]; then
      return 2
    fi
  fi
}

update_git_submodules() {
  git submodule init
  git submodule update
}

check_applescript() {
  if command -v osascript &>/dev/null; then
    # pre-req: MAC allow applescript to run in terminal
    osascript -e 'tell application "System Preferences" to quit'
    # osascript "${__dir}/macos/script/show_security_settings.applescript"
  fi
}

update_dotfiles() {
  git fetch --all
}

main() {
  typed_message 'CONFIG' "configure macOS"
  declare -a filtered=()

  # remove essential from filters if it exists
  if (( ${#filters[@]} > 0 )); then # bash < 4.3
    filtered=("${filters[@]}")
  fi
  filters=()

  if (( ${#filtered[@]} > 0 )); then # bash < 4.3
    for filter in "${filtered[@]}"; do
      if [[ "${filter}" != "essential" ]]; then
        filters+=("${filter}")
      else
        # run essential first and regardless since other things could depend on it
        run_essential
      fi
    done
  fi

  if (( ${#filters[@]} > 0 )); then
    typed_message 'RUN' "additional filters=(${filters[*]})"

    for filter in "${filters[@]}"; do
      typed_message 'RUN' "filter=${filter}"
      bash "${__dir}/packages/install.sh" "${filter}"
      # run configs if they exist
      find "${__dir}/packages/${filter}" -type file -name "config.sh" -exec bash {} \;
    done 
  else
    run_essential
    typed_message 'INSTRUCTION' "To run additional filters, run the script again with --filter <package>. Use -h for a list of available packages to filter on."
    typed_message 'INSTRUCTION' "For best results after running the first time, start in a clean tab/window. This allows scripts to use the newer bash."
  fi

  {
    echo ''
    date
    awk '/^==> Caveats/{print "\n-----\n";p=1;next} /^==>/{p=0} p' "${log_file}"
    echo '-----'
    echo ''
  } >> "${brew_caveats_log}"

  typed_message 'INSTRUCTION' "Check the output above or in ${brew_caveats_log} for any additional steps you can complete. The full log is at ${log_file} and will be replaced on the next run."
  typed_message 'INSTRUCTION' "Bash is not the login shell. If you have bash configs, add to '~/.bashrc' instead of '~/.bash_profile."
}

if [[ ${CI} == false ]]; then
  filter_opts "$@"

  date_header
  update_git_submodules
  check_applescript
  main
  
fi

# declare email
# declare hostname

# if [[ -f "${__dir}/.env" ]]; then
#   set -o allexport
#   # shellcheck source=/dev/null
#   source "${__dir}/.env"
#   set +o allexport
# else
#   echo ".env file doesn't exist. creating from .example file."
#   cp "${__dir}/.env.example" "${__dir}/.env"
#   error "IMPORTANT: edit values and re-run bootstrap." 1
# fi

# [[ -z "${email:-}" ]] && error "email is empty" 1

# echo ''

# if [[ "${DEBUG}" == true ]]; then
#   declare -p
# fi



# echo "setting up machine $(hostname) as ${hostname} for ${email}..."

# touch "${HOME}/.bash_profile"

# # export for child shells
# export email
# export hostname
# export pw
# export machineuser
# export username
# export log_file
# export apple_store_user
# export apple_store_pw

# # find the installers and run them iteratively
# find . -name install.sh | sort | while read -r installer ; do sh -c "${installer}" ; done

# sh -c "${__dir}/macos/bootstrap.sh"
# sh -c "${__dir}/system/bootstrap.sh"
# sh -c "${__dir}/git/bootstrap.sh"
# sh -c "${__dir}/jetbrains/bootstrap.sh"
# sh -c "${__dir}/vim/bootstrap.sh"
# sh -c "${__dir}/shell/bootstrap.sh"
# sh -c "${__dir}/node/bootstrap.sh"
# sh -c "${__dir}/ruby/bootstrap.sh"

# typed_message 'CLEANUP' "removing env vars"

# echo ''
# typed_message '-----' 'All installed! check for [FAIL] to fix any issues and re-run.'

# unset email
# unset hostname
# unset pw
# unset machineuser
# unset username
# unset log_file
# unset apple_store_user
# unset apple_store_pw

# killall "Terminal" &> /dev/null || true

