#!/usr/bin/env bash

#sh <(curl -s -L https://raw.githubusercontent.com/voidlinux-br/void-installer/master/install.sh)
#sh <(wget -q -O - https://raw.githubusercontent.com/voidlinux-br/void-installer/master/install.sh)
#source <(curl -s -L https://raw.githubusercontent.com/voidlinux-br/void-installer/master/install.sh)
#source <(wget -q -O - https://raw.githubusercontent.com/voidlinux-br/void-installer/master/install.sh)

#  install.sh
#  Created: 2023/23/10
#  Altered: 2023/23/10
#
#  Copyright (c) 2023-2026, Vilmar Catafesta <vcatafesta@gmail.com>
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
#  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
#  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
#  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
#  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#set -euo pipefail

# ===== CORES =====
c_reset='\033[0m'
c_red='\033[1;31m'
c_green='\033[1;32m'
c_yellow='\033[1;33m'
c_blue='\033[1;34m'

oops() {
  echo -e "${c_red}[ERRO]${c_reset} $*" >&2
  exit 1
}

log() {
  echo -e "${c_blue}[*]${c_reset} $*"
}

ok() {
  echo -e "${c_green}[OK]${c_reset} $*"
}

warn() {
  echo -e "${c_yellow}[AVISO]${c_reset} $*"
}

umask 0022

url="https://raw.githubusercontent.com/slackjeff/pdvShell/main"
files_bin=(pdvshell)
files_home=(LICENSE README.md install.sh)
files_lang=(pdvshell)
idioma=(pt-BR en es it de fr ru zh_CN zh_TW ja ko)

tmpDir="$(mktemp -d -t pdvshell.XXXXXX)"
dir_locale="usr/share/locale"

cleanup() {
  rm -rf "$tmpDir"
}
trap cleanup EXIT

# downloader
if command -v curl >/dev/null 2>&1; then
  cmdfetch() { curl -fsSL "$1" -o "$2"; }
elif command -v wget >/dev/null 2>&1; then
  cmdfetch() { wget -q "$1" -O "$2"; }
else
  oops "precisa de curl ou wget"
fi

log "usando diretório temporário: $tmpDir"

# download binários
for f in "${files_bin[@]}"; do
  log "baixando $f..."
  cmdfetch "$url/$f" "$tmpDir/$f" || oops "falha ao baixar $f"
  ok "$f baixado"
done

# extras
for f in "${files_home[@]}"; do
  log "baixando $f..."
  cmdfetch "$url/$f" "$tmpDir/$f" || oops "falha ao baixar $f"
done

# locales
for lang in "${idioma[@]}"; do
  for f in "${files_lang[@]}"; do
    target="$tmpDir/$dir_locale/$lang/LC_MESSAGES"
    mkdir -p "$target"

    if cmdfetch "$url/$dir_locale/$lang/LC_MESSAGES/$f.mo" "$target/$f.mo"; then
      ok "locale $lang"
    else
      warn "locale $lang não disponível"
    fi
  done
done

# instala locales
if [[ -d "$tmpDir/usr/share/locale" ]]; then
  log "instalando locales..."
  sudo cp -r "$tmpDir/usr/share/locale/." /usr/share/locale/
  ok "locales instalados"
fi

# instala app
log "instalando em /opt/pdvshell..."
sudo install -d /opt/pdvshell

for file in "${files_bin[@]}"; do
  sudo install -m 755 "$tmpDir/$file" "/opt/pdvshell/$file"
  ok "$file instalado"
done

# wrapper
log "criando wrapper..."
sudo tee /usr/bin/pdvshell >/dev/null <<'EOF'
#!/usr/bin/env bash
cd /opt/pdvshell
exec ./pdvshell "$@"
EOF

sudo chmod 755 /usr/bin/pdvshell
ok "wrapper criado"

echo
echo -e "${c_green}Instalação concluída!${c_reset}"
echo -e "Use: ${c_blue}pdvshell${c_reset}"
