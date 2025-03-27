#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace
CI=${CI:-false}

data_dir="${HOME}/data"

if [[ ${CI} == false ]]; then
  # shellcheck disable=SC2317  # Don't warn about unreachable commands in this function
  end () { [[ $? = 0 ]] && return; echo "[FAILED] Script failed, check the output."; exit 1; }
  trap end EXIT 
fi

prompt_for_directory () {
  read -r -p "Directory to install to, should be in your user HOME to avoid permission issues. Default [${data_dir}]: " input_dir
  data_dir="${input_dir:-${data_dir}}"
  echo "[INFO] dotfiles will create ${data_dir} if it does not exist and download the repo to that directory."
}

update_mac () {
  echo "[INFO] Running dotfiles setup on MacOS"
  update_output=$(softwareupdate --list 2>&1 | tee /dev/tty)

  if echo "${update_output}" | grep -q "No new software available"; then
      echo "[INFO] System is up to date"
  else 
      echo "[INFO] Updates available"
      read -p "Would you like to install updates? (y/n) " -n 1 -r </dev/tty
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
          echo "[INFO] Installing updates..."
          sudo softwareupdate --install --all --agree-to-license --no-scan --restart
      else
        echo "[INFO] Skipping updates"
      fi
  fi
}

install_brew () {
  if test ! "$(command -v brew)"; then
    echo "[INSTALL] Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/tty
    echo "[INSTRUCTION] Check the output above for any additional steps to complete, especially adding homebrew to your path."
    printf "\nWhen finished, type 'cont' to continue...\n"
    while read -r input < /dev/tty; do
      if [[ $input == "cont" ]]; then
        break
      else
        eval "$input"
      fi
      printf "\nEnter next command or type 'cont' to continue\n"
    done
    echo "[INFO] $(brew --version) installed"
    echo "[INFO] $(xcode-select --version) installed"
  fi
}

setup_repo () {
  if [[ -d "${data_dir}" ]]; then
    echo "[SKIP] ${data_dir} exists."
  else
    echo "[CREATE] ${data_dir}..."
    mkdir "${data_dir}"
  fi

  if [[ -d "${data_dir}/dotfiles" ]]; then
    echo "[SKIP] ${data_dir}/dotfiles exists."
  else
    echo "[CREATE] cloning kaltepeter/dotfiles to ${data_dir}/dotfiles..."
    # clone http to avoid perm issues
    git clone https://github.com/kaltepeter/dotfiles "${data_dir}/dotfiles"
  fi

  echo "[INSTRUCTION] Run the following commands in a new terminal to continue."
  printf "\n\tcd %s/dotfiles" "${data_dir}"
  printf "\n\t./bootstrap.sh\n"
}

configure_os () {
  case "$OSTYPE" in
    "darwin"*)
        update_mac
        install_brew
    ;;
    # "linux"*)
    #     # configure_linux
    # ;;
    *)
        printf '%s\n' "[ERROR] Unsupported OS detected, aborting..." >&2
        exit 1
    ;;
  esac
}

if [[ ${CI} == false ]]; then
  prompt_for_directory 
  configure_os
  setup_repo

  echo ''
  exit 0
fi