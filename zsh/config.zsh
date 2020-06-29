# shellcheck disable=SC2148
# config.zsh
ZSH_THEME="materialshell"
eval "$(pyenv init -)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=$PATH:/usr/local/opt/rabbitmq/sbin
export PATH="/usr/local/sbin:$PATH"
export TIMEFMT='%J %U user %S system %P cpu %*E total max RSS %M'
export NODE_EX=":(exclude)*lock.json"
