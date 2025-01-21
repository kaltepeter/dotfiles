#!/usr/bin/env bash
# bootstrap.sh
set -o errexit
set -o pipefail
set -o nounset
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script_name="$(basename "${BASH_SOURCE[0]}")"
log_file="${__dir}/logs/${script_name/%.*/.log}"

DEBUG=${DEBUG:-0}
((${DEBUG} >= 1)) && set -o xtrace;
((${DEBUG} >= 2)) && set -o verbose;
exec 3>&2 > >(tee "${log_file}") 2>&1

export script_name
# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/shell/lib.sh"
trap end EXIT 

date_header

filter_opts "$@"

configure_mac() {
  typed_message 'CONFIG' "configure macOS"
  sh -c "${__dir}/homebrew/install.sh"
  # Replace the manual prompt with an automatic check
  if ! op account get &>/dev/null; then
    typed_message 'CONFIG' "1Password CLI needs to be enabled. Visit https://developer.1password.com/docs/cli/app-integration/ for details."
    read -r -p "Once complete type 'cont' to continue.\n" input
    echo -e "\n"
    if [[ "$input" != "cont" ]]; then
      exit 2
    fi
  fi
  sh -c "${__dir}/macos/install.sh"

  # pre-req: MAC allow applescript to run in terminal
  osascript -e 'tell application "System Preferences" to quit'
  # osascript "${__dir}/macos/script/show_security_settings.applescript"
}

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

# declare data_dir="${HOME}/data"
# if [[ -d "${data_dir}" ]]; then
#   typed_message 'SKIP' "${data_dir} exists."
# else
#   typed_message 'CREATE' "${data_dir}...";
#   mkdir "${data_dir}"
# fi

# echo ''

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

git submodule init
git submodule update

case "$OSTYPE" in
    "darwin"*)
        configure_mac
    ;;
    # "linux"*)
    #     # configure_linux
    # ;;
    *)
        printf '%s\n' "[ERROR] Unsupported OS detected, aborting..." >&2
        exit 1
    ;;
esac

exit 0