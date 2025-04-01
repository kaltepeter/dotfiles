#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"
CI=${CI:-false}

declare filter=${1:-essential}

# shellcheck disable=SC1091
[[ $(command -v k_custom_lib_loaded) ]] || source "${__root}/shell/lib.sh"

if [[ ${CI} == false ]]; then
  trap inner_end EXIT 
fi

update_brew() {
    typed_message 'UPDATE' 'Updating Homebrew.'
    brew update

    read -r -p "Would you like to upgrade homebrew packages? [y/n]"
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        typed_message 'UPDATE' 'Updating Homebrew packages.'
        brew upgrade
    fi
    echo
}

install_brew_packages() {
  if [[ ! -f "${__dir}/${filter}/brew.txt" ]]; then 
    return 0
  fi

  typed_message 'INSTALL' 'Installing Homebrew packages.'

  declare -a formulas=()
  # bash 3 compatibility, bash 4 has mapfile
  # mapfile -t formulas < <(grep '^- ' "${__dir}/${filter}/brew.txt" | sed 's/^- //;s/[[:space:]]*$//')
  while IFS= read -r line; do
    formulas+=("${line}")
  done < <(grep '^- ' "${__dir}/${filter}/brew.txt" | sed 's/^- //;s/[[:space:]]*$//')

  for formula in "${formulas[@]}"; do
    if ! brew list --formula --versions "${formula}"; then
      brew install "${formula}" 
    fi
  done
  echo
}

install_brew_casks() {
  if [[ ! -f "${__dir}/${filter}/brew-casks.txt" ]]; then 
    return 0
  fi

  declare -a skipped_casks=()
  typed_message 'INSTALL' 'Installing Homebrew casks.'

  declare -a casks=()
  # bash 3 compatibility, bash 4 has mapfile
  # mapfile -t casks < <(grep '^- ' "${__dir}/${filter}/brew-casks.txt" | sed 's/^- //;s/[[:space:]]*$//')
  while IFS= read -r line; do
    casks+=("${line}")
  done < <(grep '^- ' "${__dir}/${filter}/brew-casks.txt" | sed 's/^- //;s/[[:space:]]*$//')

  for cask in "${casks[@]}"; do
    if ! brew list --cask --versions "${cask}"; then
      output=$(brew install --cask "${cask}" 2>&1 || true)
      echo "${output}"
      if [[ "${output}" == *"already an App at"* ]]; then
        skipped_casks+=("${cask}")
      fi
    fi
  done

  if (( ${#skipped_casks[@]} > 0 )); then
    typed_message 'SKIP' 'The following list of applications are already installed outside of brew. Remove the application and re-run to install with brew.'
    for cask in "${skipped_casks[@]}"; do
      typed_message 'SKIP' "  • ${cask}"
    done
  fi
  echo
}

if [[ ${CI} == false ]]; then
  inner_header
  case "$OSTYPE" in
      "darwin"*)
        update_brew 
        install_brew_packages
        install_brew_casks
      ;;
      # "linux"*)
      #     TODO: add linux support likely apt or apt-get, yum for some.
      # ;;
      *)
        error 'Unsupported OS detected, aborting...' 1
      ;;
  esac

  typed_message 'SUCCCESS' "${filter} packages installed."
  echo ''
  exit 0
fi