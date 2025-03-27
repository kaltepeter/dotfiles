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