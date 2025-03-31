# dotfiles

my dotfiles :)

## Pre-requisite

- Run through the mac wizard until the machine boots up.
- Sign in to iCloud
- Grant the Terminal permissions to manage apps.
    - Open System Preferences > Privacy & Security
    - Click App Management
    - Click the + button and add Terminal (localed in /Applications/Utilities)
    - Enable Terminal
    - Follow prompts to complete, you will have to quit and re-open Terminal

## Install

I encourage you to view [the script](https://raw.githubusercontent.com/kaltepeter/dotfiles/HEAD/install.sh) in your browser before executing it.

```bash
/bin/bash -c "$(curl -H -fsSL https://raw.githubusercontent.com/kaltepeter/dotfiles/HEAD/install.sh)"

# no cache, on a branch
/bin/bash -c "$(curl -H 'Cache-Control: no-cache, no-store' -fsSL https://raw.githubusercontent.com/kaltepeter/dotfiles/refs/heads/back-to-bash/install.sh\?$(date +%s))"
```

> [!NOTE]
> During development of this script you may want to replace HEAD with the branch name to avoid caching/delays in updates. Opening a fresh terminal tab also helps.

run `./bootstrap.sh -h` for info


## bootstrap

```bash
./bootstrap.sh
# DEBUG=1 ./bootstrap.sh
```

## Contributing to Existing Packages

Edit the packages `<package_manager>.txt`, `<package_manager>-casks.txt`, or `config.sh` files.

Config files can be tested, update/add tests if changing the config.sh script.

Lookup packages on the package manager's website.

- [Homebrew](https://brew.sh/)

> [!NOTE]
> For Brew, GUI apps are installed differently. When searching the package if it has `--cask` in the name it is a GUI app and should be added to the `brew-cask.txt` file instead of the `brew.txt` file. e.g. `brew install --cask google-chrome`

## Adding a New Package

There is a template script to help get started. It's setup in a way that can be tested.

- The code inside this condition `if [[ ${CI} == false ]]; then` is for running locally and interactively.
- Tests will always set `CI=true` so the code inside that condition will not run.

```bash
package_name=my_new_package
package_manager=brew
mkdir packages/${package_name}
touch packages/${package_name}/${package_manager}.txt
```

Optional steps

```bash
# Only needed if you need to install brew GUI apps
touch packages/${package_name}/brew-cask.txt

# if you need to add configuration use the template
cp template/config.sh packages/${package_name}/config.sh
# there are two spots to replace with your own code. Check out the example and then replace the 
# code between '##### replace with your own code when creating a new script #####' with your own functions.

# Add tests for config.sh. Setup/teardown is already setup. 
cp test/test_template_config.bats test/test_${package_name}_config.bats
sed -i '' "s/template/packages\/${package_name}/g" test/test_${package_name}_config.bats
# There are simple examples to help get started, replace with your own.
``` 

See the [Contributing to Existing Packages](#Contributing-to-Existing-Packages) section for details on the `*.txt` files.

### Template config.sh

#### Header Block

```bash
#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)/.."
CI=${CI:-false}
```

This sets up error handling and debugging and defaults the CI variable to false.

#### Library Load and Exit Trap

```bash
# shellcheck disable=SC1091
[[ $(command -v k_custom_lib_loaded) ]] || source "${__root}/shell/lib.sh"

if [[ ${CI} == false ]]; then
  trap inner_end EXIT 
fi
```

The local library is loaded, this contains reusable functions. The trap is an 'inner' trap that will run when the script exits. It will write a message with /${scriptname}.

#### Functions

```bash
##### replace with your own code when creating a new script #####
# shellcheck disable=SC2120
say_hello() {
    # ...
}
##### replace with your own code when creating a new script #####
```

Functions are a good way to allow the tests to run safely. Normally these are overkill for a simple script. The test will call just the functions you tell it to.

Remember to replace the block between '##### replace with your own code when creating a new script #####' with your own function definitions. The shellcheck disable=SC2120 is to allow the function to be called without arguments, this is likely not needed for your function and can also be removed.

#### End Block

```bash
if [[ ${CI} == false ]]; then
  inner_header
  ##### replace with your own code when creating a new script #####
  say_hello
  ##### replace with your own code when creating a new script #####

  echo ''
  exit 0
fi
```

This will only run without CI and is meant to be interactive. Call whatever functions you define to have them executed. The `inner_header` function will write a message with ${scriptname}.

Remember to replace the block between '##### replace with your own code when creating a new script #####' with your own function calls.

## Adding a New Package Manager

There are a couple of places to look at adding support.

[./packages/install.sh](./packages/install.sh) specically the part the mentions ` case "$OSTYPE" in`.

Adding a new txt file in the package for that package manager is also required. Casks is a concept only required for brew.

Optionally if you have additional config steps that differ check the package config.sh. Most *nix systems operate very similar and we should be able to keep it agnostic.

## Testing

`brew install bats-core`

### Testing Manually

> [!WARNING]
> Testing locally manually or with bats is at your own risk. This is intended to be a machine setup and mistakes might be a bit destructive while developing. Bats will use /tmp and create a directory for testing. Other steps may affect machine level items.

I recommend something like [UTM](https://mac.getutm.app/) with a separate image to test MacOS or a Docker image for linux to run the tests locally without modifying your local machine.

I will likely add a Docker test image when linux support is added.

> [!TIP]
>Once confident on the changes it might be ideal to run locally to ensure the scripts are idempotent and work as expected.

### CI

A non-destructive way to run tests.

GitHub actions will run the tests in the `test` directory.

- Shellcheck (https://github.com/koalaman/shellcheck)
- bats (https://github.com/bats-core/bats-core)

### Testing with bats

Uses bats. Use the local tag to only run safe local tests. You can run all or other tags if you are confident they are safe for your machine. See [Testing Manually](#testing-manually) for more info on safer ways to test machine level changes.

To run bats you will need to get the submodules.

```bash
git submodule init
git submodule update
```

```bash
bats --filter-tags "local" test 
```

Debugging with print should write to handle 3. e.g. `ls -la "${install_dir}/new-dir/ds-labs-local-setup" >&3`

## Thanks to...

* https://mathiasbynens.be/ and his [dotfiles repo](https://github.com/mathiasbynens/dotfiles)
* https://github.com/holman and his [dotfiles repo](https://github.com/holman/dotfiles) and blog post: https://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/ 
* https://medium.com/@webprolific/getting-started-with-dotfiles-43c3602fd789

## curated lists of resources

* https://github.com/webpro/awesome-dotfiles
* https://dotfiles.github.io/


## Structure

Heavily influened by Holman's dotfiles repo.
- <https://github.com/holman/dotfiles/blob/master/script/install>
- <https://github.com/mathiasbynens/dotfiles/blob/master/bootstrap.sh>