#!/usr/bin/env bash
#
# Autor:    Fernando Souza - https://www.youtube.com/@fernandosuporte/
# Data:     20/09/2026
# Homepage: 
# Licença:  MIT
# Script:   pdvshell-backup.sh
#
# Localização: /usr/local/bin/
#
#
# Descrição: Script de backup para pdvShell.
#
#
# Dessa forma, a rotina de backup fica separada do crontab, facilitando futuras alterações, 
# como retenção automática dos backups antigos ou cópia para outro disco.

# Permissão:

# chmod +x /usr/local/bin/pdvshell-backup.sh

# E no cron:

# 0 22 * * * /usr/local/bin/pdvshell-backup.sh


# Configurar o terminal para 160x47

# ----------------------------------------------------------------------------------------

# Definir cores

GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ----------------------------------------------------------------------------------------

# Detectar idioma do sistema e definir mensagens (i18n)

case "${LANG:-${LC_ALL:-${LC_MESSAGES:-C}}}" in

    pt_BR* )
        msg="O programa gettext não está instalado. Por favor, instale para continuar."
        ;;

    pt_PT* | pt* )
        msg="O programa gettext não está instalado. Por favor, instale-o para continuar."
        ;;

    es* )
        msg="El programa gettext no está instalado. Por favor, instálelo para continuar."
        ;;

    fr* )
        msg="Le programme gettext n'est pas installé. Veuillez l'installer pour continuer."
        ;;

    de* )
        msg="Das Programm gettext ist nicht installiert. Bitte installieren Sie es, um fortzufahren."
        ;;

    it* )
        msg="Il programma gettext non è installato. Per favore, installalo per continuare."
        ;;

    ja* )
        msg="gettext プログラムがインストールされていません。続行するにはインストールしてください。"
        ;;

    ru* )
        msg="Программа gettext не установлена. Пожалуйста, установите её, чтобы продолжить."
        ;;

    zh* )
        msg="未安装 gettext 程序。请安装后再继续。"
        ;;

    en* | * )
        msg="The gettext program is not installed. Please install it to continue."
        ;;
esac



# Verificar as dependências

command -v gettext >/dev/null || { echo -e "\n${RED}$msg ${NC}\n" ; exit 1; } ;

command -v tar >/dev/null     || { echo -e "\n${RED}$(gettext "tar is not installed.") ${NC}\n" ; exit 1; } ;

# ----------------------------------------------------------------------------------------

BACKUP_DIR="$HOME/pdvshell-backup" 
SOURCE=".config/pdvshell" 
DATA=$(date +%Y-%m-%d_%H-%M-%S) 


mkdir -p "$BACKUP_DIR" 

cd $HOME

tar -czf "$BACKUP_DIR/pdvshell-config-$DATA.tar.gz" "$SOURCE" 

exit 0

