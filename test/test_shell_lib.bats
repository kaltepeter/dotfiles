#!/usr/bin/env bats
declare PROJECT_ROOT

setup() {
    load 'test_helper/common-setup'
    _common_setup
    # shellcheck disable=SC1091
    source "${PROJECT_ROOT}/shell/lib.sh"

    declare script_name
}

teardown() {
    _common_teardown
    
    unset script_name
}

# bats test_tags=local,ci
@test "end should handle exit code 0" {
  run bash -c "source ${PROJECT_ROOT}/shell/lib.sh; script_name=\"test_shell_lib.sh\"; trap end EXIT; exit 0"
  
  assert_success
  assert_output --partial "[END] test_shell_lib.sh"
}

# bats test_tags=local,ci
@test "end should handle exit code non 0" {
  run bash -c "source ${PROJECT_ROOT}/shell/lib.sh; script_name=\"test_shell_lib.sh\"; trap end EXIT; exit 1"
  
  assert_failure
  assert_output --partial "[FATAL] test_shell_lib.sh failed, check the output."
}

# bats test_tags=local,ci
@test "usage should show usage" {
  run usage

  assert_output --partial "Overwrite usage function in shell script to provide help."
  assert_output --partial "Make sure you put the function after the library load."
  assert_success
}

# bats test_tags=local,ci
@test "get_colorized_prefix should show SKIP" {
  run get_colorized_prefix 'SKIP'

  assert_success
  assert_output --partial $'\033[93m[SKIP]\033[39m ...'
}

# bats test_tags=local,ci
@test "get_colorized_prefix should show FAIL" {
  run get_colorized_prefix 'FAIL'

  assert_success
  assert_output --partial $'\033[31m[FAIL]\033[39m ...'
}

# bats test_tags=local,ci
@test "get_colorized_prefix should show CLEANUP" {
  run get_colorized_prefix 'CLEANUP'

  assert_success
  assert_output --partial $'\033[94m[CLEANUP]\033[39m ...'
}

# bats test_tags=local,ci
@test "get_colorized_prefix should show CONFIG|INSTALL|UPDATE" {
  run get_colorized_prefix 'CONFIG'

  assert_success
  assert_output --partial $'\033[92m[CONFIG]\033[39m ...'

  run get_colorized_prefix 'INSTALL'

  assert_success
  assert_output --partial $'\033[92m[INSTALL]\033[39m ...'

  run get_colorized_prefix 'UPDATE'

  assert_success
  assert_output --partial $'\033[92m[UPDATE]\033[39m ...'
}

# bats test_tags=local,ci
@test "get_colorized_prefix should show INSTRUCTION" {
  run get_colorized_prefix 'INSTRUCTION'

  assert_success
  assert_output --partial $'\033[35m[INSTRUCTION]\033[39m ...'
}


# bats test_tags=local,ci
@test "get_colorized_prefix should show RUN" {
  run get_colorized_prefix 'RUN'

  assert_success
  assert_output --partial $'\033[37m[RUN]\033[39m ...'
}

# bats test_tags=local,ci
@test "error should show error and exit with exit code 1" {
    run -1 --separate-stderr error 'test error message'

    assert_stderr --partial $'\033[31mError: test error message\033[39m'
    assert_output --partial "Overwrite usage function in shell script to provide help."

    assert_failure
}

# bats test_tags=local,ci
@test "error should show error and exit with exit code 3" {
    run -3 --separate-stderr error 'test error message' 3

    assert_stderr --partial $'\033[31mError: test error message\033[39m'
    assert_output --partial "Overwrite usage function in shell script to provide help."
 
    assert_failure
}

# bats test_tags=local,ci
@test "status should show status message" {
  run status 'test status message'

  assert_success
  assert_output --partial $'\033[36mtest status message\033[39m'
}

# bats test_tags=local,ci
@test "date_header should print date and script name" {
    # shellcheck disable=SC2034
    script_name="my_script.sh"
    run date_header

    assert_success
    assert_output --partial "$(date +"%b %d")"
    assert_output --partial $'\033[36m[RUN] my_script.sh\033[39m'
}

# bats test_tags=local,ci
@test "date_header should print date without script name" {
    run date_header

    assert_success
    assert_output --partial "$(date +"%b %d")"
    assert_output --partial $'\033[36m[RUN] \033[39m'
}

# bats test_tags=local,ci
@test "typed_message should print message with type" {
    run typed_message 'FAIL' 'Error message'

    assert_success
    assert_output --partial $'        \033[31m[FAIL]\033[39m ... Error message'
}

# bats test_tags=local,ci
@test "k_custom_lib_loaded should return true" {
    is_loaded=false

    if command -v k_custom_lib_loaded &> /dev/null; then
        is_loaded=true
    fi

    
    assert [ "${is_loaded}" = "true" ]
}