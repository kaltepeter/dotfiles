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
export MOV_TO_GIF_DEFAULTS="fps=10,scale=720:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"
