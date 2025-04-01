#!/usr/bin/env bats
declare PROJECT_ROOT

setup() {
    load 'test_helper/common-setup'
    _common_setup
    # shellcheck disable=SC1091
    source "${PROJECT_ROOT}/template/config.sh"
}

teardown() {
    _common_teardown
}

# bats test_tags=local,ci
@test "say_hello should echo Hello, World!" { 
  run say_hello 'World'

  assert_output --partial "Hello, World!"
  assert_success
}

# bats test_tags=local,ci
@test "say_hello should echo Hello, Noraa!" { 
  run say_hello << EOF
Noraa

EOF

  assert_output --partial "Hello, Noraa!"
  assert_success
}