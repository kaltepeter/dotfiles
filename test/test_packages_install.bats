#!/usr/bin/env bats
declare PROJECT_ROOT

mock_brew() {
  command=${1:-}
  if [[ ${command} == "update" ]]; then
    echo "Updating Homebrew..."
  elif [[ ${command} == "upgrade" ]]; then
    echo "Upgrading 59 outdated packages..."
  elif [[ ${command} == "install" ]]; then
    echo "Installing ${2:-} ${3:-}"
  elif [[ ${command} == "list" ]]; then
    return 1
  fi
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
    set -- # prevent bats from passing test name as the first argument
    # shellcheck disable=SC1091
    source "${PROJECT_ROOT}/packages/install.sh"

    brew() {
      # shellcheck disable=SC2317
      mock_brew "$@"
    }
}

teardown() {
    _common_teardown
}

# bats test_tags=local,ci
@test "update_brew should prompt to upgrade package and upgrade if y" { 
  run update_brew << EOF
y

EOF

  assert_output --partial "$(typed_message 'UPDATE' 'Updating Homebrew.')"
  assert_output --partial "Updating Homebrew..."
  assert_output --partial "$(typed_message 'UPDATE' 'Updating Homebrew packages.')"
  assert_output --partial "Upgrading 59 outdated packages..."
  assert_success
}

# bats test_tags=local,ci
@test "update_brew should prompt to upgrade package and upgrade if not y" { 
  run update_brew << EOF
n

EOF

  assert_output --partial "$(typed_message 'UPDATE' 'Updating Homebrew.')"
  assert_output --partial "Updating Homebrew..."
  refute_output --partial "$(typed_message 'UPDATE' 'Updating Homebrew packages.')"
  refute_output --partial "Upgrading 59 outdated packages..."
  assert_success
}

# bats test_tags=local,ci
@test "install.sh should use the filter if provided" {
  # shellcheck disable=SC1091
  source "${PROJECT_ROOT}/packages/install.sh" "core"
  assert_equal "${filter}" "core"
}

# bats test_tags=local,ci
@test "install_brew_packages should install the packages" {
  filter="essential"
  run install_brew_packages

  assert_output --partial "$(typed_message 'INSTALL' 'Installing Homebrew packages.')"
  assert_output --partial "Installing git"
  refute_output --partial "Installing # update latest zsh"
  assert_success
}

# bats test_tags=local,ci
@test "install_brew_packages should skip if package is installed" { 
  # shellcheck disable=SC2317
  brew() {
    command=${1:-}
    if [[ ${command} == "list" ]]; then
      return 0
    fi
    mock_brew "$@"
  }

  export -f brew
  filter='essential'
  run install_brew_packages

  assert_output --partial "$(typed_message 'INSTALL' 'Installing Homebrew packages.')"
  refute_output --partial "Installing git"
  assert_success
}

# bats test_tags=local,ci
@test "install_brew_casks should install the packages" { 
  filter='essential'
  run install_brew_casks

  assert_output --partial "$(typed_message 'INSTALL' 'Installing Homebrew casks.')"
  assert_output --partial "Installing --cask 1password"
  refute_output --partial "Installing # update to latest version"
  assert_success
}

# bats test_tags=local,ci
@test "install_brew_casks should skip if package is installed" { 
  # shellcheck disable=SC2317
  brew() {
    command=${1:-}
    if [[ ${command} == "list" ]]; then
      return 0
    fi
    mock_brew "$@"
  }
  export -f brew

  filter='essential'
  run install_brew_casks

  assert_output --partial "$(typed_message 'INSTALL' 'Installing Homebrew casks.')"
  refute_output --partial "Installing --cask 1password"
  assert_success
}

# bats test_tags=local,ci
@test "install_brew_casks should gracefully handle apps installed outside of brew" { 
  # shellcheck disable=SC2317
  brew() {
    command=${1:-}
    if [[ ${command} == "install" ]]; then
      cask=${3:-}
      if [[ ${cask} == "google-chrome" || ${cask} == 'slack' ]]; then
        echo "Error: It seems there is already an App at '/Applications/${cask}.app'."
        return 1
      fi
    fi
    mock_brew "$@"
  }
  export -f brew

  filter='essential'
  run install_brew_casks

  assert_output --partial "$(typed_message 'INSTALL' 'Installing Homebrew casks.')"
  assert_output --partial "Installing --cask 1password"
  assert_output --partial "$(typed_message 'SKIP' 'The following list of applications are already installed outside of brew. Remove the application and re-run to install with brew.')"
  assert_output --partial "$(typed_message 'SKIP' '  • google-chrome')"
  assert_output --partial "$(typed_message 'SKIP' '  • slack')"
  refute_output --partial "$(typed_message 'SKIP' '  • 1password')"
  assert_success
}
