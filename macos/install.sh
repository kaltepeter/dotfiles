#!/usr/bin/env bash
# macos/install.sh
set -o errexit
set -o pipefail
set -o nounset
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" 
__root="$(pwd)"
__base="$(basename "${BASH_SOURCE[0]}" .sh)"
local_path="${__dir//${__root}\/}"
log_file="${__root}/logs/${local_path//\//_}_${__base}.log"
script_name="${local_path}/$(basename "${BASH_SOURCE[0]}")"
brew_caveats_log="${__root}/logs/brew_caveats.log"

DEBUG=${DEBUG:-0}
((${DEBUG} >= 1)) && set -o xtrace;
((${DEBUG} >= 2)) && set -o verbose;
exec 3>&2 > >(tee "${log_file}") 2>&1



# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__root}/shell/lib.sh"
trap end EXIT 
date_header

typed_message 'UPDATE' 'Updating app store apps.'
# TODO: will this work? it can be used in front of the redirect tee
stdbuf --output=L mas upgrade

typed_message 'INFO' 'Installed apps'
mas list 

typed_message 'INSTALL' 'Installing app store apps'
mas install 302584613 # Amazon Kindle   
mas install 411643860 # DaisyDisk       
# mas install 406056744 # Evernote 
mas install 1423210932 # Flow      
mas install 682658836 # GarageBand   
mas install 408981434 # iMovie  
mas install 409183694 # Keynote                   
mas install 441258766 # Magnet  
mas install 714196447 # MenuBar Stats 
mas install 409203825 # Numbers   
mas install 409201541 # Pages                     
mas install 1303222628 # Paprika Recipe Manager 3  
mas install 431748264 # Pluralsight               
mas install 1091675654 # Shapr3D                   
mas install 904280696 # Things                    
mas install 6472865291 # ZSA Keymapp                 

exit 0