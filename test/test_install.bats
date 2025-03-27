#!/usr/bin/env bats
declare PROJECT_ROOT
declare install_dir

setup() {
    load 'test_helper/common-setup'
    _common_setup
    # shellcheck disable=SC1091
    source "${PROJECT_ROOT}/install.sh"
}

teardown() {
    _common_teardown
}

# bats test_tags=local,ci
@test "prompt_for_directory should accept a directory when prompted" { 
    run prompt_for_directory << EOF
${install_dir} 
EOF

  assert_output --partial "[INFO] dotfiles will create ${install_dir} if it does not exist and download the repo to that directory."
  assert_success
}

# bats test_tags=local,ci
@test "prompt_for_directory should use default directory when no input is provided" {
    run prompt_for_directory << EOF

EOF
  assert_output --partial "[INFO] dotfiles will create ${HOME}/data if it does not exist and download the repo to that directory."
  assert_success
}

# bats test_tags=local,ci
@test "setup_repo should preserve directories if they exist" {
    mkdir -p "${install_dir}/dotfiles"
    touch "${install_dir}/dotfiles/file.txt"

    # shellcheck disable=SC2030
    export data_dir="${install_dir}"
    run setup_repo
    unset data_dir

    assert_output --partial "[SKIP] ${install_dir} exists."
    assert_output --partial "[SKIP] ${install_dir}/dotfiles exists."
    assert_output --partial "[INSTRUCTION] Run the following commands in a new terminal to continue."
    assert_output --partial "cd ${install_dir}/dotfiles"
    assert_output --partial "./bootstrap.sh"

    assert_file_exist "${install_dir}/dotfiles/file.txt"

    assert_success
}

# bats test_tags=local,ci
@test "setup_repo should create directory and clone repo if they do not exist" {
    # shellcheck disable=SC2031
    export data_dir="${install_dir}/new-dir"
    run setup_repo
    unset data_dir

    assert_output --partial "[CREATE] ${install_dir}/new-dir"
    assert_output --partial "[CREATE] cloning kaltepeter/dotfiles to ${install_dir}/new-dir/dotfiles"
    assert_output --partial "[INSTRUCTION] Run the following commands in a new terminal to continue."
    assert_output --partial "cd ${install_dir}/new-dir/dotfiles"
    assert_output --partial "./bootstrap.sh"

    assert_file_exist "${install_dir}/new-dir/dotfiles/README.md"

    assert_success
}

# bats test_tags=local,ci
@test "configure_os should error if os is unsupported" {
    OSTYPE="linux"
    run configure_os
    assert_output --partial "[ERROR] Unsupported OS detected, aborting..." 
    assert_failure
}

# bats test_tags=local,ci
@test "update_mac should skip updates if already updated" {
    softwareupdate () {
        # shellcheck disable=SC2317
        printf "No new software available.\n"
    }

    run update_mac 

    assert_output --partial "[INFO] Running dotfiles setup on MacOS"
    assert_output --partial "[INFO] System is up to date"

    assert_success
}

# bats test_tags=local,ci
@test "install_brew should skip if brew is already installed" {
    brew () {
        return 0
    }

    run install_brew

    refute_output --partial "[INFO] $(brew --version) installed"

    assert_success
}