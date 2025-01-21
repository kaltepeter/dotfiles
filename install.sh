#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script_name="$(basename "${BASH_SOURCE[0]}")"
log_file="${__dir}/logs/${script_name/%.*/.log}"

usage() {
  cat <<END
usage: [DEBUG=true] install.sh

Automatically write to .env file and run bootstrap.

    -h: show this help message
END
}

while getopts "h" opt; do
  case $opt in
  h)
    usage
    exit 0
    ;;
  \?)
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

end () { [[ $? = 0 ]] && return; echo "[FAILED] Script failed, check the output."; exit 1; }
trap end EXIT 

configure_mac () {
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
          softwareupdate --install --all --agree-to-license --no-scan
      else
        echo "[INFO] Skipping updates"
      fi
  fi

  # brew 
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

declare data_dir="${HOME}/data"
if [[ -d "${data_dir}" ]]; then
  echo "[SKIP] ${data_dir} exists."
else
  echo "[CREATE] ${data_dir}..."
  mkdir "${data_dir}"
fi

if [[ -d "${HOME}/data/dotfiles" ]]; then
  echo "[SKIP] ${HOME}/data/dotfiles exists."
else
  echo "[CREATE] cloning kaltepeter/dotfiles to ${HOME}/data/dotfiles..."
  # clone http to avoid perm issues
  git clone https://github.com/kaltepeter/dotfiles.git "${HOME}/data/dotfiles"
fi

echo "[INSTRUCTION] Run the following commands in a new terminal to continue."
printf "\n\tcd ${HOME}/data/dotfiles"
printf "\n\t./bootstrap.sh\n"

echo ''
exit 0
