#!/usr/bin/env bats
declare PROJECT_ROOT

setup() {
    load 'test_helper/common-setup'
    _common_setup
    # shellcheck disable=SC1091
    source "${PROJECT_ROOT}/packages/zsh/config.sh"

    declare test_zsh_custom
    test_zsh_custom="$(temp_make)"
}

teardown() {
    _common_teardown
    temp_del "${test_zsh_custom}"
}

# bats test_tags=local,ci
@test "configure_themes should create the theme directory if does not exist" { 
  ZSH_CUSTOM="${test_zsh_custom}"
  test_custom_theme_dir="${ZSH_CUSTOM}/themes"

  assert_file_not_exist "${test_custom_theme_dir}"
  run configure_themes "${test_custom_theme_dir}"

  assert_output --partial "$(typed_message 'CREATE' "${HOME}/.oh-my-zsh/custom/themes")"
  assert_file_exist "${test_custom_theme_dir}"
  assert_success
}