#!/usr/bin/env bats
declare PROJECT_ROOT

setup() {
    load 'test_helper/common-setup'
    _common_setup
    # shellcheck disable=SC1091
    source "${PROJECT_ROOT}/bootstrap.sh"

    # prevent overwrite local logs
    export log_file="${PROJECT_ROOT}/test/test_helper/install.log"
    export brew_caveats_log="${PROJECT_ROOT}/test/test_helper/brew_caveats.log"

    if [[ -f "${brew_caveats_log}" ]]; then
      rm "${brew_caveats_log}"
    fi
    touch "${log_file}"
    
    brew() {
      # shellcheck disable=SC2317
      echo "brew $*"
    }

    op() {
      # shellcheck disable=SC2317
      echo "op $*"
    }

    export -f brew
    declare -a filters
    declare machine_type
}

teardown() {
    _common_teardown
    
    unset filters
    unset machine_type
}

# bats test_tags=local,ci
@test "usage should show usage" {
  run usage

  assert_output --partial "usage: [DEBUG=1|2] ${0} [-h|--help] [--type home|work] [--filter package] [--filter other_package] "
  assert_output --partial "  --type home|work: specify the type of setup to run. home is default."
  assert_output --partial "  --filter package: specify packages to run. Invalid packages will be ignored. Pass one or many filters."
  assert_success
}

# bats test_tags=local,ci
@test "filter_opts should show help with -h" { 
  run  filter_opts -h

  assert_output --partial "usage: [DEBUG=1|2] ${0} [-h|--help] [--type home|work] [--filter package] [--filter other_package] "
  assert_success
}

# bats test_tags=local,ci
@test "filter_opts should show help with --help" { 
  run filter_opts --help

  assert_output --partial "usage: [DEBUG=1|2] ${0} [-h|--help] [--type home|work] [--filter package] [--filter other_package] "
  assert_success
}

# bats test_tags=local,ci
@test "filter_opts should show help and error with unknown option" { 
  run filter_opts --yo

  assert_output --partial "usage: [DEBUG=1|2] ${0} [-h|--help] [--type home|work] [--filter package] [--filter other_package] "
  assert_failure
}

# # bats test_tags=local,ci
# @test "filter_opts should require a filters variable" { 
#   run filter_opts

#   assert_output --partial "[ERROR] the first argument is required to be an array to store filters"
#   assert_failure
# }

# bats test_tags=local,ci
@test "filter_opts should handle no filters" { 
  # shellcheck disable=SC2030
  declare -a filters=()
  # shellcheck disable=SC2030
  declare machine_type='home'
  filter_opts

  assert [ ${#filters[@]} -eq 0 ]
  assert [ "${machine_type}" = home ]
}

# bats test_tags=local,ci
@test "filter_opts should handle single filter" { 
  # shellcheck disable=SC2030
  declare -a filters=()
  # shellcheck disable=SC2030
  declare machine_type='home'
  filter_opts --filter essential

  # shellcheck disable=SC2031
  assert [ "${filters[*]}" = 'essential' ]
  assert [ "${machine_type}" = home ]
}

# bats test_tags=local,ci
@test "filter_opts should handle multiple filters" { 
  # shellcheck disable=SC2030
  declare -a filters=()
  # shellcheck disable=SC2030
  declare machine_type='home'
  filter_opts --filter essential --filter recommended

  # shellcheck disable=SC2031
  assert [ "${filters[*]}" = 'essential recommended' ]
  assert [ "${machine_type}" = home ]
}

# bats test_tags=local,ci
@test "filter_opts should handle invalid filters" { 
  # shellcheck disable=SC2030
  declare -a filters=()
  # shellcheck disable=SC2030
  declare machine_type='home'
  filter_opts  --filter essential --filter yo

  # shellcheck disable=SC2031
  assert [ "${filters[*]}" = 'essential' ]
  assert [ "${machine_type}" = home ]
}

# bats test_tags=local,ci
@test "filter_opts should handle type" {
  # shellcheck disable=SC2030
  declare -a filters=()
  # shellcheck disable=SC2030
  declare machine_type='home'
  filter_opts --type work

  # shellcheck disable=SC2031
  assert [ ${#filters[@]} -eq 0 ]
  assert [ "${machine_type}" = work ]
}

# bats test_tags=local,ci
@test "filter_opts should handle type and filter" {
  # shellcheck disable=SC2030
  declare -a filters=()
  # shellcheck disable=SC2030
  declare machine_type='home'
  filter_opts --type work --filter essential

  assert [ ${#filters[@]} -eq 1 ]
  assert [ "${machine_type}" = work ]
}

# bats test_tags=local,ci
@test "check_1password should continue if configured" { 
  run check_1password

  refute_output --partial "$( typed_message 'CONFIG' "1Password CLI needs to be enabled. Visit https://developer.1password.com/docs/cli/app-integration/ for details.")"
  assert_success
}

# bats test_tags=local,ci
@test "check_1password should prompt if not configured" { 
  op() {
    # shellcheck disable=SC2317
    return 1
  }

  run check_1password << EOF
cont
EOF

  assert_output --partial "$( typed_message 'CONFIG' "1Password CLI needs to be enabled. Visit https://developer.1password.com/docs/cli/app-integration/ for details.")"
  assert_success
}

# bats test_tags=local,ci
@test "check_1password should exit with error if user doesn't respond with cont" { 
  op() {
    # shellcheck disable=SC2317
    return 1
  }

  run -2 check_1password << EOF
yo
EOF

  assert_output --partial "$( typed_message 'CONFIG' "1Password CLI needs to be enabled. Visit https://developer.1password.com/docs/cli/app-integration/ for details.")"
  assert_failure
}

# bats test_tags=local,ci
@test "update_git_submodules should update submodules" {
  run update_git_submodules
  assert_success
}

# bats test_tags=local,ci
@test "update_dotfiles should fetch latest" {
  git() {
    # shellcheck disable=SC2317
    echo "git $*"
  }

  run update_dotfiles

  assert_output --partial "git fetch --all"
  assert_success
}

# bats test_tags=local,ci
@test "main should handle no filters" { 
  # shellcheck disable=SC2317
  find() {
    echo "find $*"
  }

  filters=()

  run main

  assert_output --partial "$(typed_message 'CONFIG' 'configure macOS')"
  assert_output --partial "$(typed_message 'RUN' 'filter=essential')"
  assert_output --partial "find ${PROJECT_ROOT}/packages/essential -type file -name config.sh -exec bash {} ;"
  assert_output --partial "$(typed_message 'INSTRUCTION' 'To run additional filters, run the script again with --filter <package>. Use -h for a list of available packages to filter on.')"
  assert_output --partial "$(typed_message 'INSTRUCTION' "Check the output above or in ${brew_caveats_log} for any additional steps you can complete. The full log is at ${log_file}")"
  assert_output --partial "$(typed_message 'INSTRUCTION' "Bash is not the login shell. If you have bash configs, add to '~/.bashrc' instead of '~/.bash_profile.")"
  assert_success
}

# bats test_tags=local,ci
@test "main should handle filters with esential" { 
  # shellcheck disable=SC2317
  find() {
    echo "find $*"
  }
  filters=('recommended' 'essential')

  run main

  assert_output --partial "$(typed_message 'CONFIG' 'configure macOS')"
  assert_output --partial "$(typed_message 'RUN' 'filter=essential')"
  assert_output --partial "$(typed_message 'RUN' 'additional filters=(recommended)')"
  assert_output --partial "$(typed_message 'RUN' 'filter=recommended')"
  assert_output --partial "find ${PROJECT_ROOT}/packages/essential -type file -name config.sh -exec bash {} ;"
  assert_output --partial "find ${PROJECT_ROOT}/packages/recommended -type file -name config.sh -exec bash {} ;"
  assert_output --partial "$(typed_message 'INSTRUCTION' "Check the output above or in ${brew_caveats_log} for any additional steps you can complete. The full log is at ${log_file}")"
  assert_output --partial "$(typed_message 'INSTRUCTION' "Bash is not the login shell. If you have bash configs, add to '~/.bashrc' instead of '~/.bash_profile.")"
  assert_success
}

# bats test_tags=local,ci
@test "main should handle filters without esential" { 
  # shellcheck disable=SC2317
  find() {
    echo "find $*"
  }
  filters=('recommended')

  run main

  assert_output --partial "$(typed_message 'CONFIG' 'configure macOS')"
  refute_output --partial "$(typed_message 'RUN' 'filter=essential')"
  assert_output --partial "$(typed_message 'RUN' 'additional filters=(recommended)')"
  assert_output --partial "$(typed_message 'RUN' 'filter=recommended')"
  assert_output --partial "find ${PROJECT_ROOT}/packages/recommended -type file -name config.sh -exec bash {} ;"
  assert_output --partial "$(typed_message 'INSTRUCTION' "Check the output above or in ${brew_caveats_log} for any additional steps you can complete. The full log is at ${log_file}")"
  assert_output --partial "$(typed_message 'INSTRUCTION' "Bash is not the login shell. If you have bash configs, add to '~/.bashrc' instead of '~/.bash_profile.")"
  assert_success
}

# bats test_tags=local,ci
@test "main should extract caveats to logfile" { 
  export log_file="${PROJECT_ROOT}/test/test_helper/sample_install.log"

  brew() {
    echo "brew $*"
  }

  filters=()

  run main

  assert_output --partial "$(typed_message 'CONFIG' 'configure macOS')"
  assert_output --partial "$(typed_message 'RUN' 'filter=essential')"
  assert_output --partial "$(typed_message 'INSTRUCTION' 'To run additional filters, run the script again with --filter <package>. Use -h for a list of available packages to filter on.')"
  assert_output --partial "$(typed_message 'INSTRUCTION' "Check the output above or in ${brew_caveats_log} for any additional steps you can complete. The full log is at ${log_file}")"
  assert_output --partial "$(typed_message 'INSTRUCTION' "Bash is not the login shell. If you have bash configs, add to '~/.bashrc' instead of '~/.bash_profile.")"
  assert_success
  
  assert grep -q "Add the following line to your ~/.bash_profile" "${brew_caveats_log}"
}