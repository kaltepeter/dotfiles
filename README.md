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

`curl -fsSL https://raw.githubusercontent.com/kaltepeter/dotfiles/master/install.sh | bash` 

run `./bootstrap.sh -h` for info


## bootstrap

```bash
./bootstrap.sh
# DEBUG=1 ./bootstrap.sh
```

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