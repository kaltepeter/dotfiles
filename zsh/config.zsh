# shellcheck disable=SC2148
# config.zsh
ZSH_THEME="materialshell"
eval "$(pyenv init -)"

export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export PATH=$PATH:/usr/local/opt/rabbitmq/sbin
export PATH="/usr/local/sbin:$PATH"
export TIMEFMT='%J %U user %S system %P cpu %*E total max RSS %M'
export NODE_EX=":(exclude)*lock.json"
