#!/usr/bin/env bash
#
# vscode/install

set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
[[ $(command -v k_custom_lib_loaded) ]] || source "${__dir}/../shell/lib.sh"

status "${BASH_SOURCE[0]} | ..."

log_file="${log_file:-/dev/null}"

vscode_extensions_installed=()
while IFS='' read -r line; do vscode_extensions_installed+=("$line"); done < <(code --list-extensions)
vscode_extensions=( \
  1tontech.angular-material \
  ahmadawais.shades-of-purple \
  alexkrechik.cucumberautocomplete \
  Angular.ng-template \
  asciidoctor.asciidoctor-vscode \
  bbenoist.vagrant \
  bengreenier.vscode-node-readme \
  bierner.markdown-preview-github-styles \
  buenon.scratchpads \
  burkeholland.simple-react-snippets \
  castwide.solargraph \
  ChakrounAnas.turbo-console-log \
  CodeStream.codestream \
  codezombiech.gitignore \
  CoenraadS.bracket-pair-colorizer-2 \
  darkriszty.markdown-table-prettify \
  DavidAnson.vscode-markdownlint \
  dbaeumer.vscode-eslint \
  donjayamanne.githistory \
  DotJoshJohnson.xml \
  eamodio.gitlens \
  EditorConfig.EditorConfig \
  emilast.LogFileHighlighter \
  Equinusocio.vsc-material-theme \
  equinusocio.vsc-material-theme-icons \
  esbenp.prettier-vscode \
  foxundermoon.shell-format \
  gioboa.jira-plugin \
  GitHub.vscode-pull-request-github \
  groksrc.ruby \
  HaaLeo.timing \
  hbenl.vscode-jasmine-test-adapter \
  hbenl.vscode-test-explorer \
  iciclesoft.workspacesort \
  jmMeessen.jenkins-declarative-support \
  joaompinto.asciidoctor-vscode \
  johnpapa.vscode-peacock \
  jpogran.puppet-vscode \
  k--kato.intellij-idea-keybindings \
  kavod-io.vscode-jest-test-adapter \
  miclo.sort-typescript-imports \
  mikestead.dotenv \
  misogi.ruby-rubocop \
  ms-azuretools.vscode-azurefunctions \
  ms-azuretools.vscode-docker \
  ms-mssql.mssql \
  ms-python.python \
  ms-vscode-remote.remote-containers \
  ms-vscode-remote.remote-ssh \
  ms-vscode-remote.remote-ssh-edit \
  ms-vscode-remote.remote-wsl \
  ms-vscode-remote.vscode-remote-extensionpack \
  ms-vscode.azure-account \
  ms-vscode.cpptools \
  ms-vscode.powershell \
  ms-vscode.vscode-typescript-tslint-plugin \
  ms-vsliveshare.vsliveshare \
  ms-vsliveshare.vsliveshare-pack \
  msjsdiag.debugger-for-chrome \
  naco-siren.gradle-language \
  narekmal.vscode-run-git-difftool \
  npclaudiu.vscode-gn \
  nrwl.angular-console \
  Orta.vscode-jest \
  Pivotal.vscode-manifest-yaml \
  raagh.angular-karma-test-explorer \
  RandomChance.logstash \
  rebornix.ruby \
  redhat.vscode-yaml \
  ryu1kn.partial-diff \
  stpn.vscode-graphql \
  streetsidesoftware.code-spell-checker \
  svelte.svelte-vscode \
  tht13.html-preview-vscode \
  timonwong.shellcheck \
  TobiasTimm.raiju \
  Tyriar.sort-lines \
  Tyriar.theme-sapphire \
  WallabyJs.quokka-vscode \
  william-voyek.vscode-nginx \
  wingrunr21.vscode-ruby \
  xyz.plsql-language \
)

for item in ${vscode_extensions_installed[*]}; do
  # maintain list of installs, uninstall extension if not in new list
  if ! echo "${vscode_extensions[@]}" | grep -q -o "${item}"; then
    typed_message 'CLEANUP' "Uninstalling ${item}"
  fi
done

for item in ${vscode_extensions[*]}; do
    typed_message 'INSTALL' "Installing ${item}"
    # TODO: this is slow do a diff on list and only install what is needed
    code --install-extension "${item}" | tee -a "${log_file}"
done

# sync settings
vscode_user_settings="${HOME}/Library/Application Support/Code/User"
ln -snf "${__dir}/user/settings.json" "${vscode_user_settings}/settings.json"
for item in "${__dir}"/user/snippets/*; do
  ln -snf "${item}" "${vscode_user_settings}/snippets/"
done

echo ''
exit 0
