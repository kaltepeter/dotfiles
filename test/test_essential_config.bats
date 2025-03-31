#!/usr/bin/env bats
declare PROJECT_ROOT

setup() {
    load 'test_helper/common-setup'
    _common_setup
    # shellcheck disable=SC1091
    source "${PROJECT_ROOT}/packages/essential/config.sh"

    # shellcheck disable=SC2317
    brew() {
      command=${1:-}
      echo "brew $*"
      if [[ ${command} == "--prefix" ]]; then
        echo '/opt/homebrew'
      fi
    }

    export -f brew
}

teardown() {
    _common_teardown
}

# bats test_tags=ci
@test "update_shells should add brew managed shells for brew" { 
  BREW_PREFIX="$(brew --prefix)"

  run update_shells

  check_bash=$(grep -F --quiet "${BREW_PREFIX}/bin/bash" /etc/shells; echo $?)
  check_zsh=$(grep -F --quiet "${BREW_PREFIX}/bin/zsh" /etc/shells; echo $?)

  assert_equal "${check_bash}" 0
  assert_equal "${check_zsh}" 0
  assert_output --partial "$(typed_message 'CONFIG' 'Adding bash to shells')"
  assert_output --partial "$(typed_message 'CONFIG' 'Adding zsh to shells and setting as default shell.')"
  assert_success
}

# bats test_tags=local,ci
@test "update_shells should skip brew managed shells if already added" { 
  grep() {
    echo "grep $*"
    return 0
  }

  run update_shells

  refute_output --partial "$(typed_message 'CONFIG' 'Adding bash to shells')"
  refute_output --partial "$(typed_message 'CONFIG' 'Adding zsh to shells and setting as default shell.')"
  assert_success
}

# bats test_tags=local,ci
@test "configure_bashrc should error if called without bash_profile" {
  run --separate-stderr -1 configure_bashrc

  assert_stderr --partial "Bash profile not provded, first argument must be a bash profile"
  assert_failure
}

# bats test_tags=local,ci
@test "configure_bashrc should create bash_profile and add bash completion" {
  TEST_TEMP_DIR="$(temp_make)"
  test_bash_profile="${TEST_TEMP_DIR}/.bashrc"
  assert_not_exists "${test_bash_profile}"

  run configure_bashrc "${test_bash_profile}"

  assert_output --partial "$(typed_message 'CONFIG' "Adding shell completions to ${test_bash_profile}.")"
  assert_file_contains "${test_bash_profile}" ".*$(brew --prefix)/etc/profile.d/bash_completion.sh.*" grep
  assert_success
}


# bats test_tags=local,ci
@test "configure_bashrc should add bash completion if not already added" {
  TEST_TEMP_DIR="$(temp_make)"
  test_bash_profile="${TEST_TEMP_DIR}/.bashrc"
  echo "echo 'yo'" > "${test_bash_profile}"
  assert_file_not_contains "${test_bash_profile}" ".*$(brew --prefix)/etc/profile.d/bash_completion.sh.*" grep

  run configure_bashrc "${test_bash_profile}"

  assert_output --partial "$(typed_message 'CONFIG' "Adding shell completions to ${test_bash_profile}.")"
  assert_file_contains "${test_bash_profile}" ".*$(brew --prefix)/etc/profile.d/bash_completion.sh.*" grep
  assert_success
}

# bats test_tags=local,ci
@test "configure_bashrc should skip adding bash completion if already added" {
  TEST_TEMP_DIR="$(temp_make)"
  test_bash_profile="${TEST_TEMP_DIR}/.bashrc"
  run configure_bashrc "${test_bash_profile}"

  assert_output --partial "$(typed_message 'CONFIG' "Adding shell completions to ${test_bash_profile}.")"
  assert_file_contains "${test_bash_profile}" ".*$(brew --prefix)/etc/profile.d/bash_completion.sh.*" grep
  cp "${test_bash_profile}" "${test_bash_profile}.bak"

  run configure_bashrc "${test_bash_profile}"
  
  refute_output --partial "$(typed_message 'CONFIG' "Adding shell completions to ${test_bash_profile}.")"
  assert_files_equal "${test_bash_profile}.bak" "${test_bash_profile}"
  assert_success
}

# bats test_tags=local,ci
@test "configure_gitlfs should install git lfs if not installed" {
  command() {
    if [[ "${2:-}" == "git" && "${3:-}" == 'lfs' ]]; then
      return 1
    fi
  }

  git() {
    echo "git $*"
  }

  run configure_gitlfs

  assert_output --partial "$(typed_message 'CONFIG' "Installing git lfs.")"
  assert_output --partial "git lfs install"
  assert_success
}

# bats test_tags=local,ci
@test "configure_gitlfs should skip git install if installed" {
  command() {
    if [[ "${2:-}" == "git" && "${3:-}" == 'lfs' ]]; then
      return 0
    fi
  }

  git() {
    echo "git $*"
  }

  run configure_gitlfs

  refute_output --partial "$(typed_message 'CONFIG' "Installing git lfs.")"
  refute_output --partial "git lfs install"
  assert_success
}

# bats test_tags=local,ci
@test "configure_zshrc should error if called without zsh_profile" {
  run --separate-stderr -1 configure_zshrc

  assert_stderr --partial "ZSH profile not provded, first argument must be a zsh profile"
  assert_failure
}

# bats test_tags=local,ci
@test "configure_zshrc should create zsh_profile and add zsh completion" {
  TEST_TEMP_DIR="$(temp_make)"
  test_zsh_profile="${TEST_TEMP_DIR}/.zshrc"
  assert_not_exists "${test_zsh_profile}"

  run configure_zshrc "${test_zsh_profile}"

  assert_output --partial "$(typed_message 'CONFIG' "Adding shell completions to ${test_zsh_profile}.")"
  assert_file_contains "${test_zsh_profile}" ".*FPATH=$(brew --prefix)/share/zsh-completions:\$FPATH.*" grep
  assert_success
}