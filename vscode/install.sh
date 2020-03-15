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

vscode_extensions_installed=( $(code --list-extensions) )
vscode_extensions=( \
  Equinusocio.vsc-material-theme \
  TobiasTimm.raiju \
  Tyriar.theme-sapphire \
  ahmadawais.shades-of-purple \
  johnpapa.vscode-peacock \
  CoenraadS.bracket-pair-colorizer-2 \
  k--kato.intellij-idea-keybindings \
  misogi.ruby-rubocop \
  DavidAnson.vscode-markdownlint \
  ms-vscode.vscode-typescript-tslint-plugin \
  timonwong.shellcheck \
  dbaeumer.vscode-eslint \
  foxundermoon.shell-format \
  EditorConfig.EditorConfig \
  darkriszty.markdown-table-prettify \
  miclo.sort-typescript-imports \
  esbenp.prettier-vscode \
  eamodio.gitlens \
  codezombiech.gitignore \
  donjayamanne.githistory \
  GitHub.vscode-pull-request-github \
  rebornix.ruby \
  alexkrechik.cucumberautocomplete \
  ms-python.python \
  ms-azuretools.vscode-docker \
  narekmal.vscode-run-git-difftool \
  bbenoist.vagrant \
  stpn.vscode-graphql \
  joaompinto.asciidoctor-vscode \
  DotJoshJohnson.xml \
  jpogran.puppet-vscode \
  ms-vscode.cpptools \
  ms-vscode.powershell \
  mikestead.dotenv \
  RandomChance.logstash \
  redhat.vscode-yaml \
  bengreenier.vscode-node-readme \
  Angular.ng-template \
  william-voyek.vscode-nginx \
  Pivotal.vscode-manifest-yaml \
  emilast.LogFileHighlighter \
  jmMeessen.jenkins-declarative-support \
  ms-mssql.mssql \
  naco-siren.gradle-language \
  npclaudiu.vscode-gn \
  xyz.plsql-language \
  burkeholland.simple-react-snippets \
  hbenl.vscode-test-explorer \
  raagh.angular-karma-test-explorer \
  hbenl.vscode-jasmine-test-adapter \
  rtbenfield.vscode-jest-test-adapter \
  Orta.vscode-jest \
  msjsdiag.debugger-for-chrome \
  ChakrounAnas.turbo-console-log \
  nrwl.angular-console \
  HaaLeo.timing \
  buenon.scratchpads \
  WallabyJs.quokka-vscode \
  iciclesoft.workspacesort \
  streetsidesoftware.code-spell-checker \
  tht13.html-preview-vscode \
  bierner.markdown-preview-github-styles \
  gioboa.jira-plugin \
  # gayanhewa.local-history \
  ms-vsliveshare.vsliveshare-pack \
  ryu1kn.partial-diff \
)

for item in ${vscode_extensions_installed[*]}; do
  # maintain list of installs, uninstall extension if not in new list
  if [[ ! $(echo "${vscode_extensions[@]}" | grep -o "${item}") ]]; then
    typed_message 'CLEANUP' "Uninstalling ${item}"
   # code --uninstall-extension "${item}" | tee -a "${log_file}"
  fi
done

for item in ${vscode_extensions[*]}; do
    typed_message 'INSTALL' "Installing ${item}"
    code --install-extension "${item}" | tee -a "${log_file}"
done

echo ''
exit 0
